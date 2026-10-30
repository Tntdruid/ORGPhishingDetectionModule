-- Regressionstest for ORG_PHISHING.
-- Kør fra repoets rod:  lua tests/run.lua
-- Afslutter med kode 1, hvis en sag fejler.

local here = (arg and arg[0] or ""):match("^(.*)[/\\][^/\\]+$") or "."
here = here:gsub("\\", "/")
package.path = here .. "/?.lua;" .. package.path

local mock = require("mock_rspamd")
local cases = dofile(here .. "/cases.lua")
local module_path = here .. "/../lua.local.d/org_phishing.lua"

local failures = 0
local function fail(name, msg)
  failures = failures + 1
  print("FAIL  " .. name .. ": " .. msg)
end

local symbols = mock.load_module(module_path, nil)

for _, case in ipairs(cases) do
  local task = mock.scan(symbols, case)
  local errors = {}

  for _, s in ipairs(case.hit or {}) do
    if not task:has_symbol(s) then
      errors[#errors + 1] = "mangler " .. s
    end
  end
  for _, s in ipairs(case.miss or {}) do
    if task.inserted[s] then
      errors[#errors + 1] = "uventet " .. s
    end
  end
  for s, expected in pairs(case.option or {}) do
    local found = false
    for _, opt in ipairs(task.inserted[s] or {}) do
      if opt == expected then
        found = true
      end
    end
    if not found then
      errors[#errors + 1] = string.format("%s mangler option %q (fik: %s)",
        s, expected, table.concat(task.inserted[s] or {}, ","))
    end
  end
  if case.reject ~= nil then
    local rejected = task.action == "reject"
    if rejected ~= case.reject then
      errors[#errors + 1] = case.reject and "blev ikke afvist" or ("blev afvist: " .. tostring(task.message))
    end
  end

  if #errors > 0 then
    fail(case.name, table.concat(errors, "; "))
  else
    print("ok    " .. case.name)
  end
end

-- Automatisk fuzzy-læring: slået til via rspamd.conf.local
do
  local syms, learned = mock.load_module(module_path, { auto_fuzzy_flag = 6, auto_fuzzy_weight = 10 })
  mock.scan(syms, cases[1])
  if #learned == 1 and learned[1].flag == 6 and learned[1].weight == 10 then
    print("ok    Auto-fuzzy lærer afviste mails under flag 6")
  else
    fail("Auto-fuzzy", "forventede ét kald til fuzzy_check.learn med flag 6, vægt 10")
  end

  local syms_off, learned_off = mock.load_module(module_path, nil)
  mock.scan(syms_off, cases[1])
  if #learned_off == 0 then
    print("ok    Auto-fuzzy er slået fra uden indstilling")
  else
    fail("Auto-fuzzy fra", "fuzzy_check.learn blev kaldt uden auto_fuzzy_flag")
  end
end

print()
if failures > 0 then
  print(string.format("%d test fejlede", failures))
  os.exit(1)
end
print("Alle test bestået")
