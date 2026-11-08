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

-- Legitime afsendere, der kan omtale andre brands i normale kampagne-/CRM-meddelelser.
-- Disse domæner bør fortsat være gældende, selv når visningsnavnet eller teksten indeholder et brandnavn.
local trusted_sender_domains = {
  "nemlig.com",
  "activehosted.com",
  "3.dk",
  "burd.dk",
  "kristeligt-dagblad.dk",
  "paradoxinteractive.com",
  -- e-Boks advarer om ny post fra mange afsendere (fx "ny post fra Andel Energi")
  "e-boks.dk",
  -- Kirkeministeriet videresender avisartikler, der nævner brands i forbifarten
  "km.dk",
  -- Vaccinationspåmindelser, der henviser til e-Boks/MitID
  "minvaccination.dk",
  -- Generalforsamlinger for børsselskaber (login med MitID på aktionærportal)
  "computershare.dk",
  "computershare.com",
  -- Nyhedsmedier, der omtaler banker og selskaber i artikler
  "medwatch.dk", "finanswatch.dk", "itwatch.dk", "energiwatch.dk",
  "ejendomswatch.dk", "shippingwatch.dk", "mobilitywatch.dk", "agriwatch.dk",
  "policywatch.dk", "fodevarewatch.dk", "detailwatch.dk", "advokatwatch.dk",
  "borsen.dk", "berlingske.dk", "jyllands-posten.dk", "jp.dk",
  "politiken.dk", "dr.dk",
}

local trusted_newsletter_domains = {
  "digitalt.tv",
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
  -- Quoted-printable soft line breaks kan splitte ord (fx "Brin=\ng").
  -- Fjern dem før matching, så brand- og kontekstfraser stadig detekteres.
  text = tostring(text):gsub("=\r\n", ""):gsub("=\n", "")
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
  -- 'mime' henter From-headeren (den viste afsender); 1/'smtp' ville i stedet
  -- returnere konvolut-afsenderen, som ofte er et andet domæne (fx en mailudbyder)
  local from = task:get_from('mime')
  return from and from[1] and lower(from[1].domain) or nil
end

-- Afsenderen er autentificeret: DMARC består, eller (for domæner uden
-- DMARC-post, fx GLS' pakkeshop.dk) en gyldig DKIM-signatur fra samme domæne.
local function sender_authenticated(task)
  if task:has_symbol("DMARC_POLICY_ALLOW") then
    return true
  end
  if not task:has_symbol("R_DKIM_ALLOW") then
    return false
  end
  local from = from_domain(task)
  local from_base = from and from:match("([^.]+%.[^.]+)$")
  local res = task.get_symbol and task:get_symbol("R_DKIM_ALLOW")
  for _, opt in ipairs(res and res[1] and res[1].options or {}) do
    local d = lower(tostring(opt)):match("^([^:]+)")
    if d and from_base and d:match("([^.]+%.[^.]+)$") == from_base then
      return true
    end
  end
  return false
end

local function authenticated_trusted_sender(task)
  local sender_domain = from_domain(task)
  if domain_matches(sender_domain, trusted_sender_domains)
    and sender_authenticated(task)
  then
    return true
  end

  return domain_matches(sender_domain, trusted_newsletter_domains)
    and task:has_symbol("R_DKIM_ALLOW")
    and task:has_symbol("HAS_LIST_UNSUB")
end

local function authenticated_brand_trusted_sender(task, brand)
  return brand.trusted_senders
    and domain_matches(from_domain(task), brand.trusted_senders)
    and sender_authenticated(task)
end

-- Transportørernes egne domæner (brands med carrier_notification). Deres
-- meddelelser nævner pakkeshops som Meny, Netto og Coop som afhentningssted.
local carrier_domains = {}
for _, b in pairs(brands) do
  if b.carrier_notification then
    for _, d in ipairs(b.domains or {}) do
      carrier_domains[#carrier_domains + 1] = d
    end
  end
end

local function authenticated_brand_mention_sender(task, brand)
  local sender_domain = from_domain(task)
  if not sender_authenticated(task) then
    return false
  end
  if domain_matches(sender_domain, carrier_domains) then
    return true
  end
  return brand.trusted_mention_senders
    and domain_matches(sender_domain, brand.trusted_mention_senders)
end

local carrier_risky_context = {
  -- "betaling"/"payment" alene er udeladt: ordrebekræftelser har linjer som
  -- "Betaling: Betalingskort" (fx Webapoteket, der sender med DAO)
  "betal", "betale", "afgift", "gebyr", "fee", "told", "toldgebyr",
  -- "faktura"/"invoice" alene er udeladt: butikkers fakturaer nævner
  -- transportøren (fx JYSK, der sender med GLS)
  "betalingsoplysninger", "kortoplysninger",
  "betalingsverifikation", "payment verification",
  -- "konto"/"account" alene er udeladt: butikkers ordrebekræftelser nævner
  -- typisk kundekontoen (fx "point ... synlige på din konto")
  -- "login" alene er udeladt: butikker skriver fx "Nemt og uden login"
  -- (MrPerfect.dk med GLS)
  "log in", "logge på", "adgangskode",
  "password", "verify", "verification", "bekræft", "identitet",
  "identity", "konto på hold", "konto er sat på hold", "account on hold",
  "låst", "locked", "spærret", "blocked", "udløber", "expired",
}

local suspicious_context = {
  "betaling", "payment", "konto", "account", "login", "log in",
  "logge på",
  "verify", "verification", "betalingsverifikation", "payment verification",
  "betaling verificering", "bekræft", "identitet", "identity",
  "låst", "locked", "spærret", "blocked", "udløber", "expired",
  "konto på hold", "konto er sat på hold", "account on hold",
  "netværkssikkerhed", "sikkerhedsprogram", "udgående trafik", "suspenderet",
  "ikke fuldt beskyttet", "aktivér beskyttelse", "aktiver beskyttelse",
  "gendan din sikkerhed",
  "pakke", "package", "levering", "delivery", "forsendelse", "shipment",
  "afgift", "invoice", "faktura", "abonnement", "subscription",
  "spørgeskema", "survey", "questionnaire", "undersøgelse",
  "lodtrækning", "lottery", "draw", "trækning", "deltag",
  "invitation", "inviteret", "tilmelding", "register", "registrering",
  "giveaway", "gratisgave", "kampagne", "præmie", "konkurrence",
  "start spørgeskemaet", "deltag i lodtrækningen", "start spørgeskemaet og deltag",
  "tjek din mail", "oplysninger", "kontaktoplysninger", "betalingsoplysninger",
  "abonnementsbetaling", "opdater dine betalingsoplysninger", "opdatere",
  "persondata", "persondatapolitik",
  "mise à jour de sécurité", "confirmation requise", "se connecter",
  "connectez-vous", "votre compte", "vérifier", "verification requise",
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

-- Organisatorisk domæne (de to sidste labels), så fx www.matas.dk regnes som
-- samme afsender som web.matas.dk
local function base_domain(domain)
  return domain and domain:match("([^.]+%.[^.]+)$") or domain
end

-- Domænenavnet uden topdomæne (fx "jysk" for både jysk.com og jysk.dk)
local function base_label(domain)
  return domain and domain:match("([^.]+)%.[^.]+$") or domain
end

-- Værter, der ikke siger noget om afsenderen (fx XHTML-namespace)
local neutral_url_hosts = { "w3.org" }

local function authenticated_carrier_notification(task, brand, sender_domain)
  if not brand.carrier_notification
    or not sender_domain
    or not sender_authenticated(task)
    or subject_contains(task, carrier_risky_context)
    or body_contains(task, carrier_risky_context)
  then
    return false
  end

  for _, u in ipairs(task:get_urls() or {}) do
    local host = u:get_host()
    if not host then
      return false
    end

    host = lower(host):gsub("%.$", "")
    if not domain_matches(host, brand.domains)
      and not domain_matches(host, { base_domain(sender_domain) })
      and base_label(host) ~= base_label(sender_domain)
      and not domain_matches(host, neutral_url_hosts)
    then
      return false
    end
  end

  return true
end

---------------------------------------------------------------------------
-- FORFALSKNINGSKONTROL
---------------------------------------------------------------------------

-- Visningsnavne skrevet med forvekslelige tegn (fx "𝖪ɑr𝗇ɑ"): matematiske
-- Unicode-bogstaver, eller latinske bogstaver blandet med græske, kyrilliske,
-- armenske eller IPA-tegn.
local function has_homoglyphs(s)
  if not s or s == "" then
    return false
  end
  -- Mathematical Alphanumeric Symbols (U+1D400-U+1D7FF)
  if s:find("\240\157[\144-\159]") then
    return true
  end
  local confusable = s:find("[\206\207][\128-\191]")      -- græsk
    or s:find("\205[\176-\191]")                           -- græsk
    or s:find("[\208-\211][\128-\191]")                   -- kyrillisk
    or s:find("\212[\176-\191]") or s:find("\213[\128-\191]")
    or s:find("\214[\128-\143]")                           -- armensk
    or s:find("\201[\144-\191]") or s:find("\202[\128-\175]") -- IPA (fx ɑ)
  return confusable and s:find("%a") and true or false
end

-- Domænenavne, der ligner et brand (fx "streamingpotify.dk", "svindelpunktum.dk").
-- Brandets navne tages fra dets egne domæner. Generiske ord udelades, da de
-- indgår i mange almindelige domænenavne.
local lookalike_stoplist = {
  apple = true, booking = true, borger = true, bring = true, clever = true,
  magasin = true, netto = true, power = true, stark = true, sundhed = true,
  lunar = true, davidsen = true, brugsen = true, mktmail = true,
  yourserver = true, pakkeshop = true, silvan = true, matas = true,
  bilka = true, hiper = true, nemlig = true, norlys = true, telia = true,
}

local function brand_labels(brand)
  if brand._labels then
    return brand._labels
  end
  local labels, seen = {}, {}
  for _, d in ipairs(brand.domains or {}) do
    local label = lower(d):match("([^.]+)%.[^.]+$") or lower(d)
    label = label:gsub("%-", "")
    if #label >= 5 and not lookalike_stoplist[label] and not seen[label] then
      seen[label] = true
      labels[#labels + 1] = label
    end
  end
  brand._labels = labels
  return labels
end

-- Højst én redigering (indsæt, slet eller erstat) mellem a og b
local function within_one_edit(a, b)
  local la, lb = #a, #b
  if math.abs(la - lb) > 1 then
    return false
  end
  local i, j, edits = 1, 1, 0
  while i <= la and j <= lb do
    if a:byte(i) == b:byte(j) then
      i, j = i + 1, j + 1
    else
      edits = edits + 1
      if edits > 1 then
        return false
      end
      if la > lb then
        i = i + 1
      elseif lb > la then
        j = j + 1
      else
        i, j = i + 1, j + 1
      end
    end
  end
  return edits + (la - i + 1) + (lb - j + 1) <= 1
end

-- Indeholder 'label' brandnavnet eksakt (mindst 6 tegn), eller en del, der
-- kun er én redigering fra det (mindst 7 tegn)?
local function label_looks_like(label, brand_label, min_exact)
  if #brand_label >= min_exact and label:find(brand_label, 1, true) then
    return true
  end
  if #brand_label >= 7 then
    for len = #brand_label - 1, #brand_label + 1 do
      for i = 1, #label - len + 1 do
        if within_one_edit(label:sub(i, i + len - 1), brand_label) then
          return true
        end
      end
    end
  end
  return false
end

-- Domænets labels uden topdomæne, uden bindestreger, samt hele navnet samlet
local function sender_labels(domain)
  local parts = {}
  for part in lower(domain or ""):gmatch("[^.]+") do
    parts[#parts + 1] = part
  end
  table.remove(parts)
  local labels = {}
  for _, p in ipairs(parts) do
    labels[#labels + 1] = (p:gsub("%-", ""))
  end
  labels[#labels + 1] = table.concat(labels, "")
  return labels
end

local function domain_looks_like_brand(domain, brand, min_exact)
  if not domain or domain_matches(domain, brand.domains) then
    return false
  end
  for _, label in ipairs(sender_labels(domain)) do
    for _, bl in ipairs(brand_labels(brand)) do
      if label ~= bl and label_looks_like(label, bl, min_exact) then
        return true
      end
    end
  end
  return false
end

local function check_spoof(task, brand)
  local from = task:get_from('mime')
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
  local spoof_keywords = brand.spoof_keywords or brand.keywords
  for _, kw in ipairs(spoof_keywords) do
    if contains_keyword(dn, kw) then
      return true, "display-name-spoof"
    end
  end

  -- Kompakt match: "Butik-Harald-Nyborgdk" indeholder "haraldnyborg", når
  -- skilletegn fjernes. Kun lange nøgleord for at undgå tilfældige træf.
  local compact_dn = lower(dn):gsub("[%s%p]", "")
  for _, kw in ipairs(spoof_keywords) do
    local compact_kw = lower(kw):gsub("[%s%p]", "")
    if #compact_kw >= 7 and compact_dn:find(compact_kw, 1, true) then
      return true, "display-name-spoof"
    end
  end

  if has_homoglyphs(dn) then
    return true, "display-name-homoglyph"
  end

  -- Afsenderdomæne, der ligner brandet (fx "streamingpotify.dk")
  if domain_looks_like_brand(from_dom, brand, 5) then
    return true, "sender-domain-lookalike"
  end

  -- Forfalsket Reply-To
  local reply = task:get_header("Reply-To") or ""
  for _, kw in ipairs(spoof_keywords) do
    if contains_keyword(reply, kw) then
      return true, "reply-to-spoof"
    end
  end

  -- Emne, der starter med brandnavnet (fx "EasyPark AB-Opdater dine
  -- betalingsoplysninger"), fra et domæne der ikke tilhører brandet.
  -- Betroede nyhedsbrevsafsendere undtages, da de kan indlede emner med brands.
  if not authenticated_trusted_sender(task)
    and not authenticated_brand_mention_sender(task, brand)
  then
    local subject = lower(task:get_subject() or ""):gsub("^%s+", "")
    for _, kw in ipairs(spoof_keywords) do
      local needle = lower(kw)
      if subject:sub(1, #needle) == needle
        and not is_word_byte(subject:byte(#needle + 1))
      then
        return true, "subject-spoof"
      end
    end
  end

  return false
end

---------------------------------------------------------------------------
-- BRANDKONTROL
---------------------------------------------------------------------------

---------------------------------------------------------------------------
-- "KUN OMTALE": BRANDET NÆVNES, MEN MAILEN UDGIVER SIG IKKE FOR AT VÆRE DET
---------------------------------------------------------------------------

-- Defineres længere nede, men bruges af brand-callbacks (fremadrettet erklæring)
local url_free_hosting
local abused_sender_domains
local freemail_domains

-- Vendinger, hvor mailen taler som brandet eller om modtagerens konto hos det
-- (fx "din Klarna-konto", "Med venlig hilsen EasyPark", "© 2026 Spotify")
local persona_templates = {
  "din %s", "dit %s", "dine %s", "your %s",
  "%s kundeservice", "%s support", "%s team", "%s sikkerhed", "%s security",
  "%s%%-konto", "%s konto", "%s account", "%s billing", "%s premium",
  "%s%%-abonnement", "hilsen,? %s", "regards,? %s", "holdet bag %s",
  "the %s", "© ?%%d* ?%s", "hos %s", "fra %s a/s",
}

local function escape_pattern(s)
  return (s:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%0"))
end

local function mail_text(task)
  local parts = { task:get_subject() or "" }
  for _, part in ipairs(task:get_text_parts() or {}) do
    -- get_content() returnerer et rspamd_text-objekt, ikke en streng
    local c = part:get_content()
    parts[#parts + 1] = c and tostring(c) or ""
  end
  return lower(table.concat(parts, " ")):gsub("%s+", " ")
end

local function has_persona(task, brand)
  local text = mail_text(task)
  for _, kw in ipairs(brand.keywords) do
    local k = escape_pattern(lower(kw))
    for _, tpl in ipairs(persona_templates) do
      if text:find((tpl:gsub("%%s", function() return k end))) then
        return true
      end
    end
  end
  return false
end

-- DMARC består med politikken reject eller quarantine
local function strict_dmarc(task)
  if not task:has_symbol("DMARC_POLICY_ALLOW") then
    return false
  end
  local res = task.get_symbol and task:get_symbol("DMARC_POLICY_ALLOW")
  for _, opt in ipairs(res and res[1] and res[1].options or {}) do
    local o = lower(tostring(opt))
    if o == "reject" or o == "quarantine" then
      return true
    end
  end
  return false
end

-- Afsender med streng DMARC, der kun nævner brandet uden persona, links til
-- brandet, forfalskning eller tegn på misbrug: omtale, ikke efterligning.
-- Omtale i en mail helt uden links (fx privat korrespondance: "et tilbud fra
-- Kvickly"). Brand-phishing skal altid sende ofret et sted hen; QR-phishing
-- uden links fanges af ORG_PHISHING_QR_LURE.
local neutral_link_hosts = { "w3.org", "fonts.googleapis.com", "fonts.gstatic.com" }

local function linkless_mention(task, brand)
  if brand.no_mention_exemption then
    return false
  end
  for _, u in ipairs(task:get_urls() or {}) do
    local h = u:get_host()
    if h and not domain_matches(lower(h):gsub("%.$", ""), neutral_link_hosts) then
      return false
    end
  end
  return not has_persona(task, brand)
end

local function mention_only(task, brand)
  -- Generiske "brands" (fx Cloud Services) er en svindeltype, ikke et firma
  if brand.no_mention_exemption or not strict_dmarc(task) then
    return false
  end
  if task:get_header("X-Atl-Po-Triggerid") then
    return false
  end
  if abused_sender_domains and domain_matches(from_domain(task), abused_sender_domains) then
    return false
  end
  -- Private gratis mailadresser er aldrig en seriøs afsender, der "kun nævner"
  if freemail_domains and domain_matches(from_domain(task), freemail_domains) then
    return false
  end
  if url_free_hosting then
    for _, u in ipairs(task:get_urls() or {}) do
      if url_free_hosting(u) then
        return false
      end
    end
  end
  return not has_persona(task, brand)
end

local function check_brand(task, brand)
  local reasons = {}

  local keyword_match = subject_contains(task, brand.keywords)
     or header_contains(task, "From", brand.keywords)
     or header_contains(task, "Reply-To", brand.keywords)
     or body_contains(task, brand.keywords)
  local url_match = urls_match(task, brand)
  local context_keywords = brand.context_keywords or suspicious_context
  local context_match = subject_contains(task, context_keywords)
     or body_contains(task, context_keywords)
  -- extra_context_keywords supplerer den fælles liste i stedet for at erstatte den
  if not context_match and brand.extra_context_keywords then
    context_match = subject_contains(task, brand.extra_context_keywords)
       or body_contains(task, brand.extra_context_keywords)
  end
  local url_signal = url_match
     and (context_match or not brand.url_requires_context)

  if keyword_match and (context_match or url_signal) then
    reasons[#reasons+1] = "keywords"
  end

  if url_signal and keyword_match then
    reasons[#reasons+1] = "urls"
  end

  if context_match and keyword_match then
    reasons[#reasons+1] = "context"
  end

  if #reasons == 0 then
    return false
  end

  return true, table.concat(reasons, ","), url_signal
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

      if url_match and authenticated_brand_trusted_sender(task, brand) then
        logger.infox(task, "ORG_PHISHING: authenticated trusted sender ignored for %s", name)
        return false
      end

      -- Kontrol af forfalskning
      local spoof, spoof_reason = check_spoof(task, brand)
      if spoof and not task:has_symbol("ORG_PHISHING_SPOOF") then
        -- Det samme spoof-begreb kan matche flere brands i én mail; score skal kun
        -- tælles én gang for selve forfalskningen, ikke én gang per brand.
        -- Andet argument er en vægt, der ganges med symbolets score (ikke selve scoren)
        task:insert_result("ORG_PHISHING_SPOOF", 1.0, name .. ":" .. spoof_reason)
      end

      if not url_match and not spoof and linkless_mention(task, brand) then
        logger.infox(task, "ORG_PHISHING: mention without links ignored for %s", name)
        return false
      end

      if not url_match and not spoof and mention_only(task, brand) then
        logger.infox(task, "ORG_PHISHING: mention only (strict DMARC, no persona) ignored for %s", name)
        return false
      end

      if not url_match and not spoof
        and authenticated_brand_mention_sender(task, brand)
      then
        logger.infox(task, "ORG_PHISHING: authenticated sender mention ignored for %s", name)
        return false
      end

      -- Også uden link til transportøren: butikker skriver fx "Hjemlevering med
      -- PostNord" og linker kun til eget domæne (kontrolleres i funktionen)
      if not spoof
        and authenticated_carrier_notification(task, brand, sender_domain)
      then
        logger.infox(task, "ORG_PHISHING: authenticated carrier notification ignored for %s", name)
        return false
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

  rspamd_config:register_dependency(brand.symbol, "DMARC_POLICY_ALLOW")
end

---------------------------------------------------------------------------
-- SPOOF SYMBOL (Rspamd 4.1.5 requires callback)
---------------------------------------------------------------------------

rspamd_config:register_symbol({
  name = "ORG_PHISHING_SPOOF",
  score = 4.0,
  description = "Brandforfalskning opdaget",
  -- Eget group, så et max_score-loft på "phishing"-gruppen (brugt af de enkelte
  -- brandsymboler) ikke også skalerer dette symbol ned til 0
  group = "phishing_meta",

  callback = function(task)
    -- Passivt symbol: indsættes kun af brand-callbacks
    return false
  end
})

---------------------------------------------------------------------------
-- BRANDMATCH FRA FREEMAIL-AFSENDER
---------------------------------------------------------------------------

-- Brands sender ikke fra gratis mailkonti. Et brandmatch fra fx gmail.com med
-- links til andre domæner end brandets egne er et stærkt phishingtegn.
freemail_domains = {
  "gmail.com", "googlemail.com",
  "outlook.com", "outlook.dk", "hotmail.com", "hotmail.dk", "live.com", "live.dk",
  "msn.com", "yahoo.com", "yahoo.dk", "ymail.com", "aol.com",
  "icloud.com", "me.com", "mac.com",
  "gmx.com", "gmx.net", "mail.com", "proton.me", "protonmail.com",
  "zoho.com", "yandex.com", "mail.ru",
}

local function has_foreign_url(task, brand)
  for _, u in ipairs(task:get_urls() or {}) do
    local h = u:get_host()
    if h then
      h = lower(h):gsub("%.$", "")
      if not domain_matches(h, brand.domains) then
        return true
      end
    end
  end
  return false
end

rspamd_config:register_symbol({
  name = "ORG_PHISHING_FREEMAIL",
  score = 5.0,
  description = "Brandmatch fra freemail-afsender med fremmede links",
  -- Separat symbol (ikke ORG_PHISHING_SPOOF), så reject_on_spoof ikke udløses af
  -- private mails, der blot omtaler et brand
  group = "phishing_meta",

  callback = function(task)
    if not domain_matches(from_domain(task), freemail_domains) then
      return false
    end

    local matches = {}
    for name, brand in pairs(brands) do
      if task:has_symbol(brand.symbol) and has_foreign_url(task, brand) then
        matches[#matches + 1] = name
      end
    end

    if #matches == 0 then
      return false
    end

    table.sort(matches)
    return true, table.concat(matches, ",")
  end,
})

for _, brand in pairs(brands) do
  rspamd_config:register_dependency("ORG_PHISHING_FREEMAIL", brand.symbol)
end

---------------------------------------------------------------------------
-- AFSENDERDOMÆNE, DER LIGNER ET BRAND (UDEN BRANDMATCH)
---------------------------------------------------------------------------

rspamd_config:register_symbol({
  name = "ORG_PHISHING_LOOKALIKE_DOMAIN",
  score = 4.0,
  description = "Afsenderdomænet ligner et kendt brands domæne",
  group = "phishing_meta",

  callback = function(task)
    local sender_domain = from_domain(task)
    if not sender_domain then
      return false
    end
    -- Domænet tilhører et kendt brand: ikke en efterligning
    for _, brand in pairs(brands) do
      if domain_matches(sender_domain, brand.domains) then
        return false
      end
    end
    local matches = {}
    for name, brand in pairs(brands) do
      if domain_looks_like_brand(sender_domain, brand, 6) then
        matches[#matches + 1] = name
      end
    end
    if #matches == 0 then
      return false
    end
    table.sort(matches)
    return true, table.concat(matches, ",")
  end,
})

---------------------------------------------------------------------------
-- BRANDMATCH MED LINK TIL GRATIS HOSTING ELLER VIDERESTILLING
---------------------------------------------------------------------------

-- Tjenester, hvor alle kan lægge en side op eller lave en viderestilling.
-- Legitime hver for sig, men ægte brands sender ikke kunder derhen.
local free_hosting_domains = {
  "storage.googleapis.com", "firebasestorage.googleapis.com", "sites.google.com",
  "forms.gle", "firebaseapp.com", "web.app",
  "s3.amazonaws.com", "s3.dualstack.us-east-1.amazonaws.com",
  "systeme.io", "r2.dev", "pages.dev", "workers.dev", "netlify.app",
  "vercel.app", "github.io", "glitch.me", "weebly.com", "wixsite.com",
  "square.site", "webflow.io", "framer.website", "tempurl.host",
  "bit.ly", "tinyurl.com", "is.gd", "cutt.ly", "rebrand.ly", "t.ly",
  "shorturl.at", "rb.gy", "dke.to", "flowto.it", "beacons.ai", "linktr.ee",
}

function url_free_hosting(u)
  local host = u:get_host()
  if not host then
    return nil
  end
  host = lower(host):gsub("%.$", "")
  if domain_matches(host, free_hosting_domains) then
    return host
  end
  -- Åbne viderestillinger hos Google (fx www.google.com/goto?url=...)
  if host:match("^www%.google%.[%a.]+$") or host:match("^google%.[%a.]+$") then
    local path = lower(u.get_path and u:get_path() or ""):gsub("^/", "")
    if path:match("^goto") or path:match("^url") then
      return host .. "/" .. path:match("^%a+")
    end
  end
  return nil
end

rspamd_config:register_symbol({
  name = "ORG_PHISHING_FREE_HOSTING",
  score = 5.0,
  description = "Brandmatch med link til gratis hosting eller viderestilling",
  group = "phishing_meta",

  callback = function(task)
    local hit_brand = false
    for _, brand in pairs(brands) do
      if task:has_symbol(brand.symbol) then
        hit_brand = true
        break
      end
    end
    if not hit_brand then
      return false
    end
    for _, u in ipairs(task:get_urls() or {}) do
      local found = url_free_hosting(u)
      if found then
        return true, found
      end
    end
    return false
  end,
})

for _, brand in pairs(brands) do
  rspamd_config:register_dependency("ORG_PHISHING_FREE_HOSTING", brand.symbol)
end

---------------------------------------------------------------------------
-- HEADERE KOPIERET FRA ANDRE AFSENDERE ("HEADER-SALAT")
---------------------------------------------------------------------------

-- Spam, der genbruger Reply-To og List-Unsubscribe fra rigtige nyhedsbreve,
-- har tre identiteter uden indbyrdes sammenhæng: afsender, Reply-To og
-- afmeldingsdomæne, og linker til endnu et fjerde domæne.
local function header_domain(task, name, url_first)
  local value = lower(task:get_header(name) or "")
  if value == "" then
    return nil
  end
  local d = url_first and value:match("https?://([%w%.%-]+)") or nil
  d = d or value:match("@([%w%.%-]+)")
  return d and base_domain((d:gsub("%.$", ""))) or nil
end

rspamd_config:register_symbol({
  name = "ORG_PHISHING_HEADER_MISMATCH",
  score = 5.0,
  description = "Afsender, Reply-To og List-Unsubscribe peger på tre uafhængige domæner",
  group = "phishing_meta",

  callback = function(task)
    local from = base_domain(from_domain(task))
    local reply = header_domain(task, "Reply-To", false)
    local unsub = header_domain(task, "List-Unsubscribe", true)
    if not (from and reply and unsub) then
      return false
    end
    if from == reply or from == unsub or reply == unsub then
      return false
    end
    -- Linker mailen til et af de tre domæner, hænger identiteterne sammen
    for _, u in ipairs(task:get_urls() or {}) do
      local h = u:get_host()
      if h then
        local b = base_domain(lower(h):gsub("%.$", ""))
        if b == from or b == reply or b == unsub then
          return false
        end
      end
    end
    return true, string.format("%s|%s|%s", from, reply, unsub)
  end,
})

---------------------------------------------------------------------------
-- PAKKE-SVINDEL UDEN NAVNGIVEN TRANSPORTØR
---------------------------------------------------------------------------

-- Generiske "mislykket levering"-kampagner (JordanDelivery, SamuelDelivery ...)
-- skifter ordlyd hver gang. Flere typiske vendinger fra en afsender, der ikke
-- er en ægte transportør, er et stærkt signal.
local delivery_scam_phrases = {
  "attempted delivery", "delivery was unsuccessful", "delivery unsuccessful",
  "we missed you", "nobody was there", "no one was available",
  "our courier stopped by", "our driver visited", "arrange redelivery",
  "arrange a new date", "choose a new delivery", "pick a new delivery",
  "new delivery date", "new delivery day", "collection hub",
  "collection location", "pickup point", "before return",
  "before being returned", "15 business days", "15 working days",
  "tracking portal", "your tracking page",
  "levering mislykkedes", "vi kunne ikke levere", "ny leveringsdato",
}

local delivery_carrier_domains = {
  "royalmail.com", "parcelforce.com", "evri.com", "hermesworld.com",
  "dpd.co.uk", "dpd.com", "dpd.dk", "yodel.co.uk", "dhl.co.uk",
  "amazon.com", "amazon.co.uk", "amazon.de",
}

rspamd_config:register_symbol({
  name = "ORG_PHISHING_DELIVERY_SCAM",
  score = 10.0,
  description = "Flere vendinger om mislykket levering fra en ikke-transportør",
  group = "phishing_meta",

  callback = function(task)
    local sender_domain = from_domain(task)
    if sender_authenticated(task) then
      if domain_matches(sender_domain, delivery_carrier_domains) then
        return false
      end
      for _, brand in pairs(brands) do
        if brand.carrier_notification and domain_matches(sender_domain, brand.domains) then
          return false
        end
      end
    end
    local found = 0
    for _, phrase in ipairs(delivery_scam_phrases) do
      if subject_contains(task, { phrase }) or body_contains(task, { phrase }) then
        found = found + 1
      end
    end
    if found < 3 then
      return false
    end
    -- Bandens visningsnavn: <Navn>Delivery (JordanDelivery, SamuelDelivery)
    local from = task:get_from('mime')
    local dn = lower(from and from[1] and from[1].name or "")
    if dn:match("^%a+delivery$") and dn ~= "delivery" then
      return true, "named-delivery"
    end
    return true, tostring(found) .. " phrases"
  end,
})

---------------------------------------------------------------------------
-- LAGERPLADS-SVINDEL UDEN BRAND
---------------------------------------------------------------------------

-- Kampagner, der truer med sletning af filer pga. fuld lagerplads, skifter
-- skabelon og navn hele tiden (Cloudnyt, Cloudplads, CloudOverblik ...). Flere
-- forskellige trusler i samme mail fra en ikke-udbyder er et stærkt signal.
local storage_scam_phrases = {
  "lagerplads", "lagergrænse", "lagergrænsen", "lagerplads er fuld",
  "lagerplads i skyen", "lagerplan", "cloudlager", "cloudplads",
  "filer i skyen", "filer slettet", "bliver dine filer slettet",
  "kan blive slettet", "sletning af dine gemte filer", "frigøre plads",
  "frigør plads", "frigøre lagerplads", "mere lagerplads", "opdateres ikke",
  "uploads er stoppet", "sikkerhedskopieret", "0 byte ledig",
  "dit lager er fyldt", "maksimale kapacitet", "sikkerhedskopiering",
  "rydde op i dit lager", "administrer lagerplads",
  "storage is full", "storage full", "files will be deleted", "free up space",
}

local storage_providers = {
  "google.com", "apple.com", "icloud.com", "microsoft.com", "onedrive.com",
  "dropbox.com", "dropboxmail.com", "box.com", "pcloud.com",
  "jottacloud.com", "proton.me",
}

rspamd_config:register_symbol({
  name = "ORG_PHISHING_STORAGE_SCAM",
  score = 10.0,
  description = "Flere trusler om sletning pga. fuld lagerplads fra en ikke-udbyder",
  group = "phishing_meta",

  callback = function(task)
    if sender_authenticated(task)
      and domain_matches(from_domain(task), storage_providers)
    then
      return false
    end
    local found = {}
    for _, phrase in ipairs(storage_scam_phrases) do
      if subject_contains(task, { phrase }) or body_contains(task, { phrase }) then
        found[#found + 1] = phrase
      end
    end
    if #found < 3 then
      return false
    end
    return true, table.concat(found, ",", 1, math.min(#found, 4))
  end,
})

---------------------------------------------------------------------------
-- KOLD MAIL FRA FREEMAIL MED KONTAKT KUN VIA BESKEDAPPS
---------------------------------------------------------------------------

-- Svindel (falske anmeldelser, investeringer, jobtilbud) sendes typisk fra
-- en gratis mailadresse til skjulte modtagere, hvor de eneste links går til
-- WhatsApp/Telegram. Seriøse afsendere linker til deres egen hjemmeside.
local messenger_hosts = {
  "wa.me", "api.whatsapp.com", "chat.whatsapp.com", "whatsapp.com",
  "t.me", "telegram.me", "telegram.dog", "signal.me", "m.me", "line.me",
}

local function undisclosed_recipients(task)
  local to = lower(task:get_header("To") or "")
  return to == "" or to:find("undisclosed%-recipients") ~= nil
end

rspamd_config:register_symbol({
  name = "ORG_PHISHING_MESSENGER_LURE",
  score = 7.0,
  description = "Freemail til skjulte modtagere med kontakt kun via WhatsApp/Telegram",
  group = "phishing_meta",

  callback = function(task)
    if not domain_matches(from_domain(task), freemail_domains) then
      return false
    end
    if not undisclosed_recipients(task) then
      return false
    end
    local found
    for _, u in ipairs(task:get_urls() or {}) do
      local h = u:get_host()
      if h then
        h = lower(h):gsub("%.$", "")
        if not domain_matches(h, messenger_hosts) then
          return false
        end
        found = found or h
      end
    end
    if not found then
      return false
    end
    return true, found
  end,
})

---------------------------------------------------------------------------
-- QR-PHISHING (QUISHING)
---------------------------------------------------------------------------

-- Mails, der beder modtageren scanne en kode i stedet for at klikke på et link,
-- så linkfiltre og URL-blokliste ikke kan se destinationen.
local qr_scan_phrases = {
  "scan venligst koden", "scan koden nedenfor", "scan koden herunder",
  "scan qr-koden", "scan qr koden", "scan venligst qr-koden",
  "scan the qr code", "scan the code below", "please scan the code",
}

local qr_risky_context = {
  "adressebekræftelse", "bekræft", "verificer", "påkrævet", "forsinkelse",
  "returnering", "betaling", "konto", "login", "log ind", "opdater",
  "verify", "confirm", "required", "payment", "account", "delivery",
}

-- Værter, der ikke er rigtige destinationer (skrifttyper, namespaces)
local qr_neutral_hosts = { "fonts.googleapis.com", "fonts.gstatic.com", "w3.org" }

rspamd_config:register_symbol({
  name = "ORG_PHISHING_QR_LURE",
  score = 6.0,
  description = "Beder om at scanne en kode og har ingen rigtige links (quishing)",
  group = "phishing_meta",

  callback = function(task)
    if not (subject_contains(task, qr_scan_phrases) or body_contains(task, qr_scan_phrases)) then
      return false
    end
    if not (subject_contains(task, qr_risky_context) or body_contains(task, qr_risky_context)) then
      return false
    end
    -- Ægte transportører med DMARC (fx returlabels med QR-kode) undtages
    local sender_domain = from_domain(task)
    if sender_authenticated(task) then
      for _, brand in pairs(brands) do
        if brand.carrier_notification and domain_matches(sender_domain, brand.domains) then
          return false
        end
      end
    end
    for _, u in ipairs(task:get_urls() or {}) do
      local h = u:get_host()
      if h then
        h = lower(h):gsub("%.$", "")
        if not domain_matches(h, qr_neutral_hosts) then
          return false
        end
      end
    end
    return true, "no-links"
  end,
})

---------------------------------------------------------------------------
-- GOOGLE AUTOGEN FRA FREEMAIL-AFSENDER
---------------------------------------------------------------------------

-- Googles egne systemer (fx Forms/AppSheet) laver Message-ID'er som
-- <autogen-java-...@google.com>. Rigtige Google-meddelelser kommer fra Googles
-- egne domæner; fra en privat gmail.com-afsender med links ud af Google er det
-- et kendt misbrugsmønster.
local google_domains = {
  "google.com", "google.dk", "googleapis.com", "gstatic.com",
  "googleusercontent.com", "youtube.com", "gmail.com",
}

rspamd_config:register_symbol({
  name = "GOOGLE_AUTOGEN_FREEMAIL",
  score = 6.0,
  description = "Google autogen-java Message-ID fra freemail-afsender med fremmede links",
  group = "phishing_meta",

  callback = function(task)
    local mid = lower(task:get_header("Message-ID") or "")
    if not mid:find("autogen%-java%-[^@]*@google%.com") then
      return false
    end
    if not domain_matches(from_domain(task), freemail_domains) then
      return false
    end
    for _, u in ipairs(task:get_urls() or {}) do
      local h = u:get_host()
      if h then
        h = lower(h):gsub("%.$", "")
        if not domain_matches(h, google_domains) then
          return true, h
        end
      end
    end
    return false
  end,
})

---------------------------------------------------------------------------
-- HOVEDSYMBOL (SAMLER ALLE BRANDMATCH)
---------------------------------------------------------------------------

rspamd_config:register_symbol({
  name = "ORG_PHISHING",
  -- Rent informativt tag ("brands=..."); reel scoring sker via de enkelte
  -- brandsymboler for at undgå dobbelttælling og group max_score-udhuling
  score = 0.0,
  description = "Hovedsymbol for brandphishing",
  group = "phishing_meta",

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

---------------------------------------------------------------------------
-- MAIL FRA SCRIPT I HACKET WEBSITE
---------------------------------------------------------------------------

-- cPanel/Exim tilføjer X-Source-Dir med scriptets mappe. Legitim WordPress-post
-- sendes fra sidens rod eller wp-admin; et script i wp-includes, uploads eller
-- cache-mapper er typisk en webshell på en hacket side.
-- Mindst tre konsonanter (eller cifre) i træk; y regnes som vokal
local function looks_random(word)
  return word:find("[bcdfghjklmnpqrstvwxz%d][bcdfghjklmnpqrstvwxz%d][bcdfghjklmnpqrstvwxz%d]") ~= nil
end

local compromised_script_dirs = {
  "/wp%-includes/",
  "/wp%-content/uploads/",
  "/wp%-content/cache/",
  "/wp%-content/upgrade/",
  "/%.well%-known/",
}

rspamd_config:register_symbol({
  name = "ORG_PHISHING_HACKED_SITE",
  score = 6.0,
  description = "Sendt af et script i en typisk webshell-mappe (X-Source-Dir)",
  group = "phishing_meta",

  callback = function(task)
    local dir = lower(task:get_header("X-Source-Dir") or "")
    if dir == "" then
      return false
    end
    for _, pattern in ipairs(compromised_script_dirs) do
      if dir:find(pattern) then
        return true, (pattern:gsub("%%", ""))
      end
    end
    -- Phishingkit, der lægger sig i tre tilfældige mapper på 7 tegn
    -- (fx /public_html/ndysmgz/kiwxlym/pmdvkor). Tilfældige navne har klumper
    -- af mindst tre konsonanter; almindelige ord (library, vendors) har ikke.
    local seg = "([%l%d][%l%d][%l%d][%l%d][%l%d][%l%d][%l%d])"
    local a, b, c = dir:match("/" .. seg .. "/" .. seg .. "/" .. seg .. "/?$")
    if a and looks_random(a) and looks_random(b) and looks_random(c) then
      return true, "random-dirs"
    end
    return false
  end,
})

---------------------------------------------------------------------------
-- MISBRUG AF JIRA SERVICE MANAGEMENT
---------------------------------------------------------------------------

-- Svindlere opretter gratis Jira-sider (*.atlassian.net) og sender phishing via
-- funktionen til kundeinvitationer, så SPF/DKIM/DMARC består for atlassian.net.
rspamd_config:register_symbol({
  name = "ORG_PHISHING_JIRA_ABUSE",
  score = 6.0,
  description = "Kundeinvitation fra Jira Service Management med links ud af Atlassian",
  group = "phishing_meta",

  callback = function(task)
    local trigger = lower(task:get_header("X-Atl-Po-Triggerid") or "")
    if not trigger:find("jsm%-cn%-customer%-invite") then
      return false
    end
    if not domain_matches(from_domain(task), { "atlassian.net" }) then
      return false
    end
    for _, u in ipairs(task:get_urls() or {}) do
      local h = u:get_host()
      if h then
        h = lower(h):gsub("%.$", "")
        if not domain_matches(h, { "atlassian.net", "atlassian.com" }) then
          return true, h
        end
      end
    end
    return false
  end,
})

---------------------------------------------------------------------------
-- FORVEKSLELIGE TEGN UDEN BRANDMATCH
---------------------------------------------------------------------------

-- Ord, der blander latinske bogstaver med græske/kyrilliske/armenske/IPA-tegn
-- (fx "Кοnto"). Mindst to ASCII-bogstaver, så enheder som "10kΩ" og "μm"
-- ikke rammer.
local function has_homoglyph_word(text)
  for token in tostring(text):gmatch("%S+") do
    local _, ascii = token:gsub("%a", "")
    if ascii >= 2 and has_homoglyphs(token) then
      return true
    end
  end
  return false
end

rspamd_config:register_symbol({
  name = "ORG_PHISHING_HOMOGLYPH",
  score = 6.0,
  description = "Visningsnavn eller ord skrevet med forvekslelige tegn",
  group = "phishing_meta",

  callback = function(task)
    local reasons = {}
    local from = task:get_from('mime')
    local dn = from and from[1] and from[1].name or ""
    if has_homoglyphs(dn) then
      reasons[#reasons + 1] = "display-name"
    end
    if has_homoglyph_word(task:get_subject() or "") then
      reasons[#reasons + 1] = "subject"
    end
    for _, part in ipairs(task:get_text_parts() or {}) do
      local c = part:get_content()
      if c and has_homoglyph_word(c) then
        reasons[#reasons + 1] = "body"
        break
      end
    end
    if #reasons == 0 then
      return false
    end
    return true, table.concat(reasons, ",")
  end,
})

---------------------------------------------------------------------------
-- KAMPAGNEFINGERAFTRYK
---------------------------------------------------------------------------

-- Kendte phishingkampagner, der genbruger samme footer på tværs af brands
-- (fx falske Punktum.dk- og Spotify-fakturaer). Alle grupper i 'all_of' skal
-- matche (mindst ét udtryk pr. gruppe). En gruppe med 'header = "..."' matches
-- mod den header i stedet for emne og brødtekst. Afsendere fra
-- 'except_domains' undtages.
local campaign_fingerprints = {
  {
    -- Punktum dk A/S' ægte CVR og adresse, kopieret ind i falske footere
    name = "PUNKTUM_FOOTER",
    all_of = {
      { "cvr 24210375" },
      { "Ørestads Blvd. 108", "ørestads blvd. 108",
        "Ørestads Boulevard 108", "ørestads boulevard 108" },
    },
    except_domains = { "punktum.dk", "dk-hostmaster.dk" },
  },
  {
    -- Dansk "lagerplads i skyen"-kampagne (Cloudnyt, CloudOverblik m.fl.)
    -- med de faste felter "Dine billeder / Dine filer / Dine e-mails"
    name = "CLOUD_STORAGE_DK",
    all_of = {
      { "lagerplads i skyen" },
      { "dine billeder" },
      { "dine filer" },
      { "dine e-mails" },
    },
    except_domains = {},
  },
  {
    -- EasyPark-phishing via kapret SendGrid-konto med Reply-To til en
    -- amerikansk klinik
    name = "REPLYTO_SCOTTSDALE",
    all_of = {
      { header = "Reply-To", "scottsdalerheumatologycenter.com" },
    },
    except_domains = {},
  },  {
    -- Spansk-hostet kampagne (Klarna, PayPal m.fl.) med knappen "Verificer
    -- Konto" skrevet med kyrillisk К og græsk ο (rå entitet eller afkodet)
    name = "VERIFICER_KONTO_HOMOGLYPH",
    all_of = {
      -- Uden "Verificer": Klarna-varianten har et usynligt tegn foran ordet
      { "К&omicron;nto", "Кοnto" },
    },
    except_domains = {},
  },
  {
    -- "Cloud®"-kampagne via Google autogen (betalingsoplysninger)
    name = "CLOUD_REG_DK",
    all_of = {
      { "cloud®-kontoadministration" },
      { "dine filer, sikkert opbevaret" },
    },
    except_domains = {},
  },
  {
    -- Falsk e-Boks/MitID-besked med fejloversat tekst ("Danmarks mest
    -- anvendte hopvinna selskaber")
    name = "EBOKS_HOPVINNA",
    all_of = {
      { "hopvinna" },
    },
    except_domains = { "e-boks.dk", "e-boks.com" },
  },
  {
    -- Generisk engelsk "missed delivery"-skabelon uden navngivet transportør
    name = "MISSED_DELIVERY_EN",
    all_of = {
      { "we missed you today" },
      { "our courier stopped by" },
    },
    except_domains = {
      "royalmail.com", "parcelforce.com", "evri.com", "hermesworld.com",
      "dpd.co.uk", "dpd.com", "dpd.dk", "yodel.co.uk", "dhl.com", "dhl.co.uk",
      "ups.com", "fedex.com", "gls-group.eu", "postnord.com", "postnord.dk",
      "amazon.com", "amazon.co.uk", "amazon.de",
    },
  },
  {
    -- UPS' footer kopieret til falske transportører ("ParcelLink, the
    -- ParcelLink brandmark, and the colour brown are trademarks ...")
    name = "UPS_FOOTER_CLONE",
    all_of = {
      { "the colour brown are trademarks", "the color brown are trademarks" },
    },
    except_domains = { "ups.com" },
  },
}

rspamd_config:register_symbol({
  name = "ORG_PHISHING_CAMPAIGN",
  score = 10.0,
  description = "Kendt phishingkampagne (genbrugt footer)",
  group = "phishing_meta",

  callback = function(task)
    local sender_domain = from_domain(task)
    for _, fp in ipairs(campaign_fingerprints) do
      if not domain_matches(sender_domain, fp.except_domains) then
        local all = true
        for _, group in ipairs(fp.all_of) do
          local matched
          if group.header then
            matched = header_contains(task, group.header, group)
          else
            matched = subject_contains(task, group) or body_contains(task, group)
          end
          if not matched then
            all = false
            break
          end
        end
        if all then
          return true, fp.name
        end
      end
    end
    return false
  end,
})

---------------------------------------------------------------------------
-- AFVISNING VED BRANDMATCH + FORFALSKNING
---------------------------------------------------------------------------

-- Afsenderdomæner, hvis konti gentagne gange er kapret til brand-phishing
-- (fx en SendGrid-konto, der sender falske EasyPark-mails)
abused_sender_domains = {
  "reviewmgr.com",
}

-- Brands med 'reject_on_spoof = true' afvises direkte, når både brandsymbolet
-- og ORG_PHISHING_SPOOF har ramt. Et brandmatch alene giver fortsat kun score.
-- Kun forfalsket visningsnavn/Reply-To afviser; subject-spoof er for svagt et
-- signal alene (fx nyhedsbreve med emnet "Spotify hæver prisen ...").
local reject_spoof_reasons = {
  ["display-name-spoof"] = true,
  ["reply-to-spoof"] = true,
  ["display-name-homoglyph"] = true,
  ["sender-domain-lookalike"] = true,
}

-- Brandmatch + visningsnavn med forvekslelige tegn afvises for alle brands,
-- også uden reject_on_spoof
local function spoof_is_homoglyph(task)
  local res = task.get_symbol and task:get_symbol("ORG_PHISHING_SPOOF")
  for _, opt in ipairs(res and res[1] and res[1].options or {}) do
    if tostring(opt):match(":display%-name%-homoglyph$") then
      return true
    end
  end
  return false
end

local function spoof_allows_reject(task)
  local res = task.get_symbol and task:get_symbol("ORG_PHISHING_SPOOF")
  local opts = res and res[1] and res[1].options
  if not opts or #opts == 0 then
    -- Ukendt grund: bevar tidligere adfærd
    return true
  end
  for _, opt in ipairs(opts) do
    local reason = tostring(opt):match(":(.+)$")
    if reason and reject_spoof_reasons[reason] then
      return true
    end
  end
  return false
end

-- Automatisk fuzzy-læring (valgfri). Slås til i rspamd.conf.local:
--   org_phishing { auto_fuzzy_flag = 6; auto_fuzzy_weight = 10; }
-- Mails, modulet selv afviser, læres så direkte via fuzzy_check under det flag.
local org_opts = rspamd_config:get_all_opt("org_phishing") or {}
local auto_fuzzy_flag = tonumber(org_opts.auto_fuzzy_flag)
local auto_fuzzy_weight = tonumber(org_opts.auto_fuzzy_weight) or 10

local function auto_fuzzy_learn(task)
  if not auto_fuzzy_flag then
    return
  end
  local fc = rspamd_plugins and rspamd_plugins["fuzzy_check"]
  if not (fc and fc.learn) then
    logger.infox(task, "ORG_PHISHING: fuzzy_check.learn ikke tilgængelig; auto-fuzzy sprunget over")
    return
  end
  local ok, err = pcall(fc.learn, task, auto_fuzzy_flag, auto_fuzzy_weight)
  if ok then
    logger.infox(task, "ORG_PHISHING: auto-fuzzy lært (flag %s, vægt %s)",
      auto_fuzzy_flag, auto_fuzzy_weight)
  else
    logger.infox(task, "ORG_PHISHING: auto-fuzzy fejlede: %s", err)
  end
end

-- Markør for mails, modulet selv afviser (vises i webgrænsefladen med grund).
rspamd_config:register_symbol({
  name = "ORG_PHISHING_REJECTED",
  score = 0.0,
  description = "Afvist af ORG_PHISHING (markør til automatisk fuzzy-læring)",
  group = "phishing_meta",

  callback = function(task)
    -- Passivt symbol: indsættes kun af ORG_PHISHING_REJECT
    return false
  end
})

rspamd_config:register_symbol({
  name = "ORG_PHISHING_REJECT",
  type = "postfilter",
  -- Samme mekanisme som Rspamds force_actions-modul (set_pre_result i postfilter)
  callback = function(task)
    -- Kendt kampagnefingeraftryk afvises uanset brand og forfalskning
    -- Pakke-svindel med bandens visningsnavn (<Navn>Delivery) afvises
    local ds = task.get_symbol and task:get_symbol("ORG_PHISHING_DELIVERY_SCAM")
    for _, opt in ipairs(ds and ds[1] and ds[1].options or {}) do
      if tostring(opt) == "named-delivery" then
        logger.infox(task, "ORG_PHISHING: rejecting named delivery scam")
        task:insert_result("ORG_PHISHING_REJECTED", 1.0, "delivery-scam")
        auto_fuzzy_learn(task)
        task:set_pre_result("reject", "Phishing rejected (delivery scam)", "org_phishing")
        return
      end
    end

    if task:has_symbol("ORG_PHISHING_CAMPAIGN") then
      logger.infox(task, "ORG_PHISHING: rejecting known campaign")
      task:insert_result("ORG_PHISHING_REJECTED", 1.0, "campaign")
      auto_fuzzy_learn(task)
      task:set_pre_result("reject", "Phishing rejected (known campaign)", "org_phishing")
      return
    end

    -- Brandmatch fra en hacket website eller misbrugt platform (Jira, Google
    -- autogen fra Gmail) afvises
    -- for alle brands
    local abused = task:has_symbol("ORG_PHISHING_HACKED_SITE") and "hacked-site"
      or task:has_symbol("ORG_PHISHING_JIRA_ABUSE") and "jira-abuse"
      or task:has_symbol("GOOGLE_AUTOGEN_FREEMAIL") and "google-autogen"
      or domain_matches(from_domain(task), abused_sender_domains) and "abused-sender"
    if abused then
      local hacked = {}
      for name, brand in pairs(brands) do
        if task:has_symbol(brand.symbol) then
          hacked[#hacked + 1] = name
        end
      end
      if #hacked > 0 then
        table.sort(hacked)
        local which = table.concat(hacked, ",")
        logger.infox(task, "ORG_PHISHING: rejecting brand mail via %s (%s)", abused, which)
        task:insert_result("ORG_PHISHING_REJECTED", 1.0, abused .. ":" .. which)
        auto_fuzzy_learn(task)
        task:set_pre_result("reject", "Phishing rejected (" .. abused .. ")", "org_phishing")
        return
      end
    end

    if not task:has_symbol("ORG_PHISHING_SPOOF")
      or not spoof_allows_reject(task)
    then
      return
    end

    local homoglyph = spoof_is_homoglyph(task)
    local matches = {}
    for name, brand in pairs(brands) do
      if (brand.reject_on_spoof or homoglyph) and task:has_symbol(brand.symbol) then
        matches[#matches + 1] = name
      end
    end

    if #matches == 0 then
      return
    end

    table.sort(matches)
    local which = table.concat(matches, ",")
    logger.infox(task, "ORG_PHISHING: rejecting brand spoof (%s)", which)
    task:insert_result("ORG_PHISHING_REJECTED", 1.0, "spoof:" .. which)
    auto_fuzzy_learn(task)
    task:set_pre_result("reject", "Phishing rejected (brand spoof)", "org_phishing")
  end,
})

logger.infox("ORG_PHISHING: alle brandsymboler registreret")

return true