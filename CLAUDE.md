# ORG_PHISHING – rspamd-modul

Lua-modul til rspamd, der fanger brand-phishing mod danske brugere.
GitHub: `Tntdruid/ORGPhishingDetectionModule`. Driftes på rspamd 4.2.3+ (DirectAdmin, Exim), afvisningsgrænse 20.

## Filer

- `lua.local.d/org_phishing.lua` – logik: brandmatch, forfalskning, undtagelser og generiske symboler
  (lookalike, free hosting, homoglyffer, hackede sites, lagerplads- og pakkesvindel, kampagnefingeraftryk)
  samt postfilteret `ORG_PHISHING_REJECT`.
- `lua.local.d/org_phishing_brands.lua` – brands: `keywords`, `domains`, `extra_context_keywords`,
  `spoof_keywords`, `reject_on_spoof`, `carrier_notification`, `url_requires_context`, `no_mention_exemption` m.fl.
- `tests/cases.lua` – regressionssager (`hit`, `miss`, `option`, `reject`). `tests/run.lua` kører hver sag
  to gange (normal + streng DMARC). `tests/mock_rspamd.lua` efterligner rspamd-API'et.
- `README.md` (versionsbadge), `changelog.md`, `releases.md` (afsnittet "## Ikke udgivet endnu").
- `examples/` – konfiguration til fuzzy_check og `rspamd.conf.local` (auto-fuzzy flag 6).

## Arbejdsgang

Brugeren sender .eml-filer:
- **"spam"** → find ud af hvorfor den ikke blev fanget/afvist (læs X-Spamd-Result), ret reglerne.
- **"ikke spam"** → falsk positiv; find den undtagelse der mangler, uden at åbne for svindel.

For hver rettelse:
1. Ret i brands- eller modulfilen; foretræk generelle regler frem for enkelte afsendere.
2. Tilføj en sag i `tests/cases.lua` (gerne en der fejlede før rettelsen).
3. Kør `lua tests/run.lua` – skal ende med "Alle test bestået".
4. Tilføj en linje under "## Ikke udgivet endnu" i både `changelog.md` og `releases.md`.

## "push" = release

1. `lua tests/run.lua` (stop ved fejl).
2. Omdøb "## Ikke udgivet endnu" til `## X.Y.Z - <dato>` i `changelog.md` og `releases.md`; bump badge i `README.md`.
3. Commit "Release vX.Y.Z", tag `vX.Y.Z`, push main + tag.
4. `gh release create vX.Y.Z --title "vX.Y.Z" --notes-file <changelog-punkterne>`.
5. Fortæl brugeren hvilke filer der skal kopieres til serveren og at rspamd skal genstartes.

## Regler der aldrig må brydes

- Mail fra `vaccination@minvaccination.dk` må aldrig blokeres.
- rspamd kører LuaJIT (Lua 5.1): brug ikke `table.unpack`, `goto`, `//` eller andet fra Lua 5.2+.
- `part:get_content()` returnerer rspamd_text – brug `tostring()` før strengoperationer.
- Symbol-options sendes som separate værdier (tabel), ikke kommasepareret tekst (rspamd 4.3 procent-koder komma).
- `insert_result`-vægten ganges med symbolets score – brug 1.0.
