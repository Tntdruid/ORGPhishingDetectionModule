-- ORG_PHISHING: Detects phishing pretending to be known service brands
-- Modern modular version with brand table, context patterns, URL + spoof matching
-- Compatible with Rspamd 4.2.0

local logger = require "rspamd_logger"
logger.infox("ORG_PHISHING: module loaded")

---------------------------------------------------------------------------
-- LOWERCASE HELPER
---------------------------------------------------------------------------

local function lower(s)
  return s and tostring(s):lower() or ""
end

---------------------------------------------------------------------------
-- DOMAIN MATCH (supports wildcard patterns)
---------------------------------------------------------------------------

local function domain_matches(domain, list)
  domain = lower(domain or "")
  for _, candidate in ipairs(list) do
    local pattern = lower(candidate)
    if not pattern:find("%%", 1, true) then
      pattern = pattern:gsub("%.", "%%."):gsub("%-", "%%-")
    end
    if domain:match("^" .. pattern .. "$")
       or domain:match("^.+%." .. pattern .. "$")
    then
      return true
    end
  end
  return false
end

---------------------------------------------------------------------------
-- BRAND DEFINITIONS
---------------------------------------------------------------------------

-- 'require' can't see lua.local.d, so load the brands file by explicit path
local rspamd_paths = rspamd_paths or {}
local this_dir = debug.getinfo(1, "S").source:match("^@(.*)/[^/]+$") or (rspamd_paths['LOCAL_CONFDIR'] and (rspamd_paths['LOCAL_CONFDIR'] .. '/lua.local.d'))
local brands = dofile(this_dir .. "/org_phishing_brands.lua")

---------------------------------------------------------------------------
-- TEXT MATCH HELPERS
---------------------------------------------------------------------------

local function contains_any(text, patterns)
  if not text then return false end
  local t = lower(text)
  for _, p in ipairs(patterns) do
    if t:find(lower(p), 1, true) then
      return true
    end
  end
  return false
end

local function subject_contains(task, patterns)
  return contains_any(task:get_subject(), patterns)
end

local function header_contains(task, hdr, patterns)
  return contains_any(task:get_header(hdr), patterns)
end

local function body_contains(task, patterns)
  local parts = task:get_text_parts()
  if not parts then return false end
  for _, part in ipairs(parts) do
    local c = part:get_content()
    if c and contains_any(c, patterns) then
      return true
    end
  end
  return false
end

local suspicious_context = {
  "betaling", "payment", "konto", "account", "login", "log in",
  "verify", "verification", "bekræft", "identitet", "identity",
  "låst", "locked", "spærret", "blocked", "udløber", "expired",
  "pakke", "package", "levering", "delivery", "forsendelse", "shipment",
  "afgift", "invoice", "faktura", "abonnement", "subscription",
}

local function urls_match(task, brand)
  for _, u in ipairs(task:get_urls() or {}) do
    local h = u:get_host()
    if h then
      h = lower(h):gsub("%.$", "")
      if domain_matches(h, brand.domains) then
        return true
      end
    end
  end
  return false
end

---------------------------------------------------------------------------
-- SPOOF DETECTION
---------------------------------------------------------------------------

local function check_spoof(task, brand)
  local from = task:get_from(1)
  if not from or not from[1] or not from[1].domain then
    return false
  end

  local from_dom = lower(from[1].domain)

  -- Legit domain → not spoof
  if domain_matches(from_dom, brand.domains) then
    return false
  end

  -- Display-name spoof
  local dn = lower(from[1].name or "")
  for _, kw in ipairs(brand.keywords) do
    if dn:find(lower(kw), 1, true) then
      return true, "display-name-spoof"
    end
  end

  -- Reply-To spoof
  local reply = lower(task:get_header("Reply-To") or "")
  for _, kw in ipairs(brand.keywords) do
    if reply:find(lower(kw), 1, true) then
      return true, "reply-to-spoof"
    end
  end

  -- DKIM spoof: DKIM valid, domain not in legit list
  if task:has_symbol("R_DKIM_ALLOW") then
    if not domain_matches(from_dom, brand.domains) then
      return true, "dkim-spoof"
    end
  end

  return false
end

---------------------------------------------------------------------------
-- BRAND CHECK
---------------------------------------------------------------------------

local function check_brand(task, brand)
  local reasons = {}

  local keyword_match = subject_contains(task, brand.keywords)
     or header_contains(task, "From", brand.keywords)
     or header_contains(task, "Reply-To", brand.keywords)
     or body_contains(task, brand.keywords)
  local url_match = urls_match(task, brand)
  local context_match = subject_contains(task, suspicious_context)
     or body_contains(task, suspicious_context)

  if keyword_match and (context_match or url_match) then
    reasons[#reasons+1] = "keywords"
  end

  if url_match and keyword_match then
    reasons[#reasons+1] = "urls"
  end

  if context_match and keyword_match then
    reasons[#reasons+1] = "context"
  end

  if #reasons == 0 then
    return false
  end

  return true, table.concat(reasons, ",")
end

---------------------------------------------------------------------------
-- REGISTER BRAND SYMBOLS
---------------------------------------------------------------------------

for name, brand in pairs(brands) do
  rspamd_config:register_symbol({
    name = brand.symbol,
    score = brand.score,
    description = "Brand phishing: " .. name,
    group = "phishing",

    callback = function(task)
      local hit, reasons = check_brand(task, brand)
      if not hit then
        return false
      end

      -- Whitelist legit domains
      local from = task:get_from(1)
      if from and from[1] and from[1].domain then
        if domain_matches(from[1].domain, brand.domains) then
          logger.infox(task, "ORG_PHISHING: %s whitelisted (%s)", name, from[1].domain)
          return false
        end
      end

      -- Spoof detection
      local spoof, spoof_reason = check_spoof(task, brand)
      if spoof then
        task:insert_result("ORG_PHISHING_SPOOF", 4.0, name .. ":" .. spoof_reason)
      end

      logger.infox(task, "ORG_PHISHING: matched %s (%s)", name, reasons)
      return true, reasons
    end,
  })
end

---------------------------------------------------------------------------
-- SPOOF SYMBOL (Rspamd 4.1.5 requires callback)
---------------------------------------------------------------------------

rspamd_config:register_symbol({
  name = "ORG_PHISHING_SPOOF",
  score = 4.0,
  description = "Brand spoofing detected",
  group = "phishing",

  callback = function(task)
    -- Passive symbol: only inserted by brand callbacks
    return false
  end
})

---------------------------------------------------------------------------
-- MASTER SYMBOL (SUMS ALL BRAND HITS)
---------------------------------------------------------------------------

rspamd_config:register_symbol({
  name = "ORG_PHISHING",
  score = 12.0,
  description = "Master brand phishing symbol",
  group = "phishing",

  callback = function(task)
    for name, brand in pairs(brands) do
      if task:has_symbol(brand.symbol) then
        return true, "brand=" .. name
      end
    end
    return false
  end
})

logger.infox("ORG_PHISHING: all brand symbols registered")

return true