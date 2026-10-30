-- Minimal simulering af Rspamd's Lua-API til regressionstest af ORG_PHISHING.
-- Dækker kun det, modulet bruger: rspamd_config, rspamd_logger, rspamd_plugins
-- og task-objektet.

local M = {}

-- Indlæser modulet med (valgfri) indstillinger fra rspamd.conf.local og
-- returnerer de registrerede symboler i registreringsrækkefølge.
function M.load_module(module_path, opts)
  local symbols = {}
  local learned = {}

  package.loaded["rspamd_logger"] = {
    infox = function() end,
  }

  rspamd_config = {
    register_symbol = function(_, def)
      symbols[#symbols + 1] = def
    end,
    register_dependency = function() end,
    get_all_opt = function(_, name)
      if name == "org_phishing" then
        return opts
      end
    end,
  }

  rspamd_plugins = {
    fuzzy_check = {
      learn = function(_, flag, weight)
        learned[#learned + 1] = { flag = flag, weight = weight }
        return true
      end,
    },
  }

  local chunk = assert(loadfile(module_path))
  chunk()

  return symbols, learned
end

-- Bygger et task-objekt ud fra en testsag.
local function new_task(case)
  local inserted = {}
  local preset = {}
  for _, s in ipairs(case.symbols or {}) do
    preset[s] = true
  end

  local headers = {}
  for k, v in pairs(case.headers or {}) do
    headers[k] = v
  end
  if not headers["From"] then
    headers["From"] = string.format("%s <x@%s>", case.from_name or "", case.from_domain or "")
  end

  local t = { inserted = inserted, action = nil, message = nil }

  function t:get_subject() return case.subject or "" end
  function t:get_header(name) return headers[name] end
  function t:get_from() return { { domain = case.from_domain, name = case.from_name or "" } } end
  function t:get_text_parts()
    return { { get_content = function() return case.body or "" end } }
  end
  function t:get_urls()
    local r = {}
    -- "host" eller "host/sti"
    for _, u in ipairs(case.urls or {}) do
      local host, path = u:match("^([^/]+)/?(.*)$")
      r[#r + 1] = {
        get_host = function() return host end,
        get_path = function() return path end,
      }
    end
    return r
  end
  function t:has_symbol(name) return preset[name] or inserted[name] ~= nil end
  function t:insert_result(name, _, opt)
    inserted[name] = inserted[name] or {}
    if opt then
      table.insert(inserted[name], tostring(opt))
    end
  end
  function t:get_symbol(name)
    if inserted[name] then
      return { { options = inserted[name] } }
    end
  end
  function t:set_pre_result(action, message)
    t.action = action
    t.message = message
  end

  return t
end

-- Kører alle normale symboler i registreringsrækkefølge og derefter postfiltre.
function M.scan(symbols, case)
  local task = new_task(case)
  for pass = 1, 2 do
    for _, def in ipairs(symbols) do
      local is_post = def.type == "postfilter"
      if (pass == 1 and not is_post) or (pass == 2 and is_post) then
        local ok, opt = def.callback(task)
        if ok then
          task:insert_result(def.name, 1.0, opt)
        end
      end
    end
  end
  return task
end

return M
