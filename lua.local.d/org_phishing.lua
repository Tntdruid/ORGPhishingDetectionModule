-- ORG_PHISHING: Opdager phishing, der udgiver sig for at komme fra kendte brands
-- Moderne modulær version med brandtabel, kontekstmønstre samt URL- og forfalskningsmatch
-- Kompatibel med Rspamd 4.2.0

local logger = require "rspamd_logger"
logger.infox("ORG_PHISHING: modul indlæst")

---------------------------------------------------------------------------
-- HJÆLPEFUNKTION TIL SMÅ BOGSTAVER
---------------------------------------------------------------------------

local function lower(s)
  return s and tostring(s):lower() or ""
end

---------------------------------------------------------------------------
-- DOMÆNEMATCH (understøtter jokertegn)
---------------------------------------------------------------------------

local function domain_matches(domain, list)
  if not domain or not list then
    return false
  end

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
-- BRANDDEFINITIONER
---------------------------------------------------------------------------

-- 'require' kan ikke se lua.local.d, så brandfilen indlæses via en eksplicit sti
local rspamd_paths = rspamd_paths or {}
local this_dir = debug.getinfo(1, "S").source:match("^@(.*)/[^/]+$") or (rspamd_paths['LOCAL_CONFDIR'] and (rspamd_paths['LOCAL_CONFDIR'] .. '/lua.local.d'))
local brands = dofile(this_dir .. "/org_phishing_brands.lua")

-- Førstepartsafsendere, hvis normale meddelelser kan omtale andre brands.
local trusted_sender_domains = {
  "nemlig.com",
}

---------------------------------------------------------------------------
-- HJÆLPEFUNKTIONER TIL TEKSTMATCH
---------------------------------------------------------------------------

local function is_word_byte(byte)
  return byte and (byte >= 128
    or byte >= 48 and byte <= 57
    or byte >= 65 and byte <= 90
    or byte >= 97 and byte <= 122
    or byte == 95)
end

local function contains_keyword(text, keyword)
  local start = 1
  local value = lower(text)
  local needle = lower(keyword)

  while true do
    local match_start, match_end = value:find(needle, start, true)
    if not match_start then
      return false
    end

    local before = match_start > 1 and value:byte(match_start - 1) or nil
    local after = match_end < #value and value:byte(match_end + 1) or nil
    if not is_word_byte(before) and not is_word_byte(after) then
      return true
    end

    start = match_end + 1
  end
end

local function contains_any(text, patterns)
  if not text then return false end
  for _, p in ipairs(patterns) do
    if contains_keyword(text, p) then
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

local function from_domain(task)
  local from = task:get_from(1)
  return from and from[1] and lower(from[1].domain) or nil
end

local function authenticated_trusted_sender(task)
  return domain_matches(from_domain(task), trusted_sender_domains)
    and task:has_symbol("DMARC_POLICY_ALLOW")
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
-- FORFALSKNINGSKONTROL
---------------------------------------------------------------------------

local function check_spoof(task, brand)
  local from = task:get_from(1)
  local from_dom = from_domain(task)
  if not from_dom then
    return false
  end

  -- Legitimt domæne betyder, at det ikke er en forfalskning
  if domain_matches(from_dom, brand.domains) then
    return false
  end

  -- Forfalsket visningsnavn
  local dn = from and from[1] and from[1].name or ""
  for _, kw in ipairs(brand.keywords) do
    if contains_keyword(dn, kw) then
      return true, "display-name-spoof"
    end
  end

  -- Forfalsket Reply-To
  local reply = task:get_header("Reply-To") or ""
  for _, kw in ipairs(brand.keywords) do
    if contains_keyword(reply, kw) then
      return true, "reply-to-spoof"
    end
  end

  return false
end

---------------------------------------------------------------------------
-- BRANDKONTROL
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

  return true, table.concat(reasons, ","), url_match
end

---------------------------------------------------------------------------
-- REGISTRÉR BRANDSYMBOLER
---------------------------------------------------------------------------

for name, brand in pairs(brands) do
  rspamd_config:register_symbol({
    name = brand.symbol,
    score = brand.score,
    description = "Brand phishing: " .. name,
    group = "phishing",

    callback = function(task)
      local hit, reasons, url_match = check_brand(task, brand)
      if not hit then
        return false
      end

      -- Whitelist legitime domæner
      local sender_domain = from_domain(task)
      if domain_matches(sender_domain, brand.domains) then
        logger.infox(task, "ORG_PHISHING: %s whitelisted (%s)", name, sender_domain)
        return false
      end

      -- Kontrol af forfalskning
      local spoof, spoof_reason = check_spoof(task, brand)
      if spoof then
        task:insert_result("ORG_PHISHING_SPOOF", 4.0, name .. ":" .. spoof_reason)
      end

      if authenticated_trusted_sender(task)
        and name ~= "NEMLIG"
        and not url_match
        and not spoof
      then
        logger.infox(task, "ORG_PHISHING: trusted sender mention ignored for %s", name)
        return false
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
  description = "Brandforfalskning opdaget",
  group = "phishing",

  callback = function(task)
    -- Passivt symbol: indsættes kun af brand-callbacks
    return false
  end
})

---------------------------------------------------------------------------
-- HOVEDSYMBOL (SAMLER ALLE BRANDMATCH)
---------------------------------------------------------------------------

rspamd_config:register_symbol({
  name = "ORG_PHISHING",
  score = 12.0,
  description = "Hovedsymbol for brandphishing",
  group = "phishing",

  callback = function(task)
    local matches = {}
    for name, brand in pairs(brands) do
      if task:has_symbol(brand.symbol) then
        matches[#matches + 1] = name
      end
    end

    if #matches == 0 then
      return false
    end

    table.sort(matches)
    return true, "brands=" .. table.concat(matches, ",")
  end
})

logger.infox("ORG_PHISHING: alle brandsymboler registreret")

return true