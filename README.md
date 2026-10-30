<p align="center">
  <img src="https://img.shields.io/badge/Rspamd-Brand%20Phishing%20Module-blue?style=for-the-badge&logo=lua&logoColor=white" alt="Rspamd Brand Phishing Module">
</p>

<h1 align="center">ORG Phishing-detekteringsmodul</h1>

<p align="center">
  Avanceret brandbaseret phishing-detektering til Rspamd 4.2.0+<br>
  Understøtter danske og internationale brands, URL-regler, mistænkelig kontekst og afsenderforfalskning.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/version-1.27.0-blue?style=flat-square" alt="Version 1.27.0">
  <img src="https://img.shields.io/badge/Rspamd-4.2.0+-green?style=flat-square" alt="Rspamd 4.2.0+">
  <img src="https://img.shields.io/badge/Lua-5.1-blueviolet?style=flat-square" alt="Lua 5.1">
  <img src="https://img.shields.io/badge/status-production_success-success?style=flat-square" alt="Production success">
  <img src="https://img.shields.io/badge/license-MIT-lightgrey?style=flat-square" alt="MIT License">
</p>

[GitHub-projekt](https://github.com/Tntdruid/ORGPhishingDetectionModule)

Et modulært Lua-regelsæt til Rspamd, der opdager phishing-mails, som udgiver sig for at komme fra kendte organisationer og tjenester.

Filteret kontrollerer meddelelsens indhold, afsenderdata, URL'er, mistænkelig konto- eller betalingskontekst samt udvalgte tegn på forfalskning. Branddefinitionerne holdes adskilt fra detekteringslogikken, så nye brands kan tilføjes uden at ændre matcheren.
Klarna-reglen genkender også blandede Unicode- og HTML-entitetsstavemåder, der skjuler brandnavnet i kontoverificeringsmails.
Mistænkelig kontekst omfatter også franske kontobekræftelsesfraser, så brandphishing på fransk ikke afhænger af URL-match alene.

## Krav

- Rspamd 4.2.0 eller nyere (testet i drift med 4.2.3)
- En Rspamd-installation med adgang til den lokale Lua-konfigurationsmappe

Modulet bruger Rspamd Task API og forventer, at `lua.local.d` findes under den lokale konfigurationsmappe.

## Installation

Kopiér begge Lua-filer til Rspamd-mappen `lua.local.d`:

```text
lua.local.d/org_phishing.lua
lua.local.d/org_phishing_brands.lua
```

Ved en standardinstallation er destinationsmappen typisk en af disse:

```text
/etc/rspamd/lua.local.d/
/usr/local/etc/rspamd/lua.local.d/
```

Valider derefter konfigurationen, og genindlæs Rspamd:

```bash
rspamadm configtest
systemctl reload rspamd
```

Brug den tilsvarende genindlæsningskommando til din platform, hvis Rspamd administreres på en anden måde.

## Detekteringsadfærd

Hvert brand kan definere:

- `keywords`: navne og fraser, der findes i emne, headers eller brødtekst
- `context_keywords`: brand-specifikke risikofraser; udelades feltet, bruges den fælles kontekstliste
- `url_requires_context`: kræver også en risikofrase, når en brand-URL findes
- `domains`: legitime domæner og underdomæner, der er knyttet til brandet
- `score`: den score, der tildeles, når brandets symbol matcher

Et brandmatch kræver et brand-keyword sammen med mistænkelig kontekst eller en URL, der matcher brandet. Brands med generiske navne kan kræve brand-specifik risikokontekst, også når en URL matcher. Legitime afsenderdomæner whitelistes for det pågældende brand. Godkendte betroede afsendere kan konfigureres globalt i `org_phishing.lua` eller for et enkelt brand i `org_phishing_brands.lua`; de undertrykker kun tekstmatch, mens brand-URL'er og tegn på forfalskning stadig kontrolleres. Modulet kontrollerer også:

- MitID-reglen genkender stavevarianten `MitlD` sammen med mistænkelig kontekst som en opfordring til at logge på.
- forfalskning af visningsnavn, også når brandnavnet er skrevet sammen med skilletegn eller ekstra tegn (fx "Butik-Harald-Nyborgdk"; gælder nøgleord på mindst 7 tegn)
- forfalskning af Reply-To
- emne, der starter med brandnavnet, fra et domæne der ikke tilhører brandet
- visningsnavn med forvekslelige tegn (homoglyffer), fx matematiske Unicode-bogstaver eller latinske bogstaver blandet med græske/kyrilliske tegn; sammen med et brandmatch afvises mailen for alle brands
- undtagelser for godkendte betroede afsendere ved tekstomtale af andre brands

DMARC-godkendte meddelelser fra `burd.dk` kan omtale andre brands, som Burd leverer
for, uden at udløse et brandmatch alene på grund af tekstomtalen. Det samme gælder
tekstomtaler i godkendte meddelelser fra `kristeligt-dagblad.dk`, `km.dk` og
`paradoxinteractive.com`; brand-URL'er og tegn på forfalskning udløser stadig
kontrol. Redaktionelle nyhedsbreve fra `digitalt.tv` med godkendt DKIM og
`List-Unsubscribe` behandles tilsvarende som betroede tekstomtaler.
DMARC-godkendte nyhedsbreve fra `tv2kosmopol.dk` kan omtale TV 2 Play og Bilka
uden at udløse tekstbaserede brandmatches; brand-URL'er og tegn på
afsenderforfalskning kontrolleres fortsat. TV 2 Play's spoofkontrol bruger
specifikke stavemåder af tjenestens navn, mens indholdsmatch også genkender
`TV 2`.
DMARC-godkendte meddelelser fra `yousee.dk` og `e.telenor.dk` kan omtale MitID
uden et brandmatch; MitID-links og tegn på afsenderforfalskning kontrolleres
fortsat.
Apple-reglen bruger målrettede konto- og sikkerhedsfraser i stedet for den
fælles liste med brede ord som "bekræft" og "tilmelding". Cloud Services,
Power, Nets, Steam, Booking.com, UPS og Bring bruger ligeledes målrettet
kontekst, og brand-URL'er er ikke tilstrækkelige alene for disse brands.
For Bring omfatter den målrettede kontekst også sporingslokkemidler som
"spor din pakke" og "sporingsnummer".
Apple, Spotify og TV 2 Play kræver også mistænkelig kontekst, før links til brandets
eget domæne tæller, da artikler og nyhedsbreve ofte linker til
`itunes.apple.com`, `open.spotify.com` og `tv2.dk`.
Cloud Services matcher ikke længere generiske Google-, Dropbox- eller
OneDrive-domæner. Apple-app-links i DMARC-godkendte meddelelser fra
`postnord.com` ignoreres fortsat.
DMARC-godkendte meddelelser fra `e-boks.dk` (inkl. `advisering.e-boks.dk`) kan
omtale alle brands, fx "Du har fået ny post fra Andel Energi", uden et brandmatch;
brand-links og afsenderforfalskning kontrolleres fortsat.
DMARC-godkendte meddelelser fra `e-boks.dk` kan omtale NyKredit uden et
brandmatch; NyKredit-links og tegn på afsenderforfalskning kontrolleres fortsat.
DMARC-godkendte meddelelser fra `advisering.e-boks.dk` kan omtale Coop uden et
brandmatch; Coop-links og tegn på afsenderforfalskning kontrolleres fortsat.
DMARC-godkendte meddelelser fra transportørernes egne domæner kan omtale andre
brands, fx pakkeshops som "Pakkeshop Meny", uden et brandmatch; brand-links og
afsenderforfalskning kontrolleres fortsat.
Forsendelsesmeddelelser fra transportørbrands kræver ikke en særskilt butiksliste:
de ignoreres, når afsenderen består DMARC, linkene kun går til afsenderens eget
domæne eller transportørens domæner, og meddelelsen ikke indeholder betalings-
eller loginanmodninger. Dette gælder PostNord, DAO, Burd, GLS, DHL, FedEx, UPS og Bring.
Det dækker også butikkers ordrebekræftelser (fx Matas, der sender med Burd), hvor
linkene går til butikkens eget domæne (inkl. andre underdomæner og samme navn under
et andet topdomæne, fx jysk.com/jysk.dk) eller transportøren.
Omtale af kundekontoen ("konto") eller fakturaen ("faktura") regnes ikke som
risikokontekst her.

URL- og afsenderdomæner matches uden hensyn til store og små bogstaver. Underdomæner til konfigurerede domæner accepteres, og jokertegn understøttes.

## Registrerede symboler

| Symbol | Formål | Standardscore |
| --- | --- | ---: |
| `ORG_PHISHING` | Hovedsymbol, når et eller flere brandsymboler matcher | 12.0 |
| `ORG_PHISHING_SPOOF` | Ekstra resultat ved opdaget brandforfalskning | 4.0 |
| `ORG_PHISHING_<BRAND>` | Individuelt brandmatch | Se brandfilen |
| `ORG_PHISHING_CAMPAIGN` | Kendt kampagnefingeraftryk (fx genbrugt footer med CVR og adresse, eller en fast Reply-To); afvises altid | 10.0 |
| `ORG_PHISHING_HOMOGLYPH` | Visningsnavn, emne eller ord i teksten skrevet med forvekslelige tegn (fx "ᏢɑуΡɑI" eller "Кοnto"), også uden brandmatch | 6.0 |
| `GOOGLE_AUTOGEN_FREEMAIL` | Google `autogen-java`-Message-ID fra en freemail-afsender med links uden for Google (misbrug af fx Google Forms/AppSheet) | 6.0 |
| `ORG_PHISHING_HACKED_SITE` | Sendt af et script i en typisk webshell-mappe ifølge `X-Source-Dir` (fx `wp-includes`, `wp-content/uploads`); sammen med et brandmatch afvises mailen for alle brands | 6.0 |
| `ORG_PHISHING_JIRA_ABUSE` | Kundeinvitation fra Jira Service Management (`*.atlassian.net`) med links ud af Atlassian; sammen med et brandmatch afvises mailen for alle brands | 6.0 |
| `ORG_PHISHING_REJECTED` | Markør, når modulet selv afviser en mail; bruges til automatisk fuzzy-læring | 0.0 |
| `ORG_PHISHING_FREEMAIL` | Brandmatch fra en freemail-afsender (fx gmail.com) med links til andre domæner end brandets | 5.0 |
| `ORG_PHISHING_REJECT` | Postfilter, der afviser mailen ved brandmatch + forfalskning for brands med `reject_on_spoof = true` | – |

Brands med `reject_on_spoof = true` i brandfilen afvises direkte, når både
brandsymbolet og `ORG_PHISHING_SPOOF` rammer samme mail. Et brandmatch uden
forfalskning giver fortsat kun score. Kun forfalsket visningsnavn eller
Reply-To udløser afvisning; `subject-spoof` giver kun score. I øjeblikket gælder
dette Punktum.dk, Spotify, SKAT, Hetzner, Harald Nyborg, Cloud Services, Saphe, e-Boks og MitID.

De individuelle brandsymboler dækker i øjeblikket:

- YouSee
- PostNord
- Coop
- Netflix
- OpenAI
- Cloud Services
- Apple
- Spotify
- Steam
- Booking.com
- Viaplay
- TV 2 Play
- MobilePay
- MitID
- e-Boks
- Digital Post
- Punktum.dk
- Hetzner
- Saphe
- Danske Bank
- Nordea
- JYSK
- Magasin
- Jyske Bank
- Sydbank
- Lunar
- Arbejdernes Landsbank
- Nykredit
- Nets
- PayPal
- EasyPark
- Klarna
- DAO
- Burd
- GLS
- DHL
- FedEx
- UPS
- Saxo Bank
- Interactive Brokers
- Andel Energi
- Tryg
- Topdanmark
- Alm. Brand
- Elgiganten
- Skat
- Sygeforsikringen danmark
- borger.dk
- Sundhed.dk
- Udbetaling Danmark
- DSB
- Rejsekort
- Telenor
- Telmore
- Telia
- CBB
- OiSTER
- 3
- EWII
- Fastspeed
- Hiper
- NRGi
- Norlys
- Salling Group
- Waoo
- MENY
- Bilka
- føtex
- Lidl
- Power
- Bauhaus
- Silvan
- STARK
- XL-BYG
- Bygma
- Davidsen
- Jem & Fix
- Harald Nyborg
- 10-4
- Johannes Fog
- Matas
- Netto
- REMA 1000
- OK
- Clever
- Nemlig.com
- Bring
- Wolt
- BroBizz

## Tilføjelse af et brand

Redigér `lua.local.d/org_phishing_brands.lua`, og tilføj en ny post efter den eksisterende struktur:

```lua
EXAMPLE = {
  symbol = "ORG_PHISHING_EXAMPLE",
  score = 8.0,
  keywords = {
    "example",
  },
  domains = {
    "example.com",
  },
},
```

Brug `context_keywords` til at erstatte den fælles mistænkelige kontekst for et
brand, eller `extra_context_keywords` til at supplere den (fx sammensatte ord som
"skattekonto", der ikke matcher det fælles ord "konto").

Sørg for, at symbolnavnet er unikt. Kør `rspamadm configtest`, og genindlæs Rspamd efter ændringer i brandfilen.

## Automatisk fuzzy-læring (valgfrit)

Mails, som modulet selv afviser (kampagnefingeraftryk, forvekslelige tegn eller
forfalsket visningsnavn/Reply-To for brands med `reject_on_spoof`), får markøren
`ORG_PHISHING_REJECTED` og kan læres automatisk i den lokale fuzzy-lagring. Så
rammer gentagelser af samme kampagneskabelon fuzzy med det samme, også når
afsender og ordlyd skifter.

1. Tilføj et ledigt fuzzy-flag (fx 6, `LOCAL_FUZZY_ORG`) til din lokale
   fuzzy-regel, og giv symbolet en vægt i `fuzzy_group.conf`. Se
   `examples/fuzzy_check.conf`. Reglen må ikke være `read_only`.
2. Slå funktionen til i `rspamd.conf.local` med
   `org_phishing { auto_fuzzy_flag = 6; auto_fuzzy_weight = 10; }`. Se
   `examples/rspamd.conf.local`.
3. Kør `rspamadm configtest`, og genindlæs Rspamd. Loggen viser
   `ORG_PHISHING: auto-fuzzy lært`, når en mail læres.

Uden `auto_fuzzy_flag` er funktionen slået fra. Automatisk lærte hashes ligger
under deres eget flag, så de kan vægtes for sig og ryddes uden at røre manuelt
tilføjede hashes.

## Test

Test altid konfigurationssyntaksen før genindlæsning:

```bash
rspamadm configtest
```

### Regressionstest

Repoet indeholder en regressionstest, der kører modulet mod en simuleret Rspamd
(kræver kun Lua 5.1+ eller LuaJIT, ikke Rspamd):

```bash
lua tests/run.lua
```

Sagerne i `tests/cases.lua` er forkortede versioner af rigtige phishing-mails og
legitime mails, der tidligere gav falske markeringer (fx JYSK med GLS, Matas med
Burd og PostNord med Pakkeshop Meny). Hver sag angiver, hvilke symboler der skal
og ikke må ramme, og om mailen skal afvises. Tilføj en sag, når en ny kampagne
eller falsk markering rettes, så rettelsen ikke går tabt senere.

### Test på serveren

Til funktionstest kan du sende repræsentative testmeddelelser gennem Rspamd og kontrollere de returnerede symboler og scores. Test både mistænkte phishing-mails og legitime meddelelser fra konfigurerede domæner for at kontrollere whitelist-adfærden.

## Bemærkninger

Dette er et heuristisk phishing-regelsæt. Det bør supplere Rspamds indbyggede regler, godkendelseskontroller og omdømmesystemer i stedet for at erstatte dem. Gennemgå matches, og justér scores til dit mailflow, før reglerne bruges som grundlag for automatisk afvisning.

## Licens

Dette projekt udgives under [MIT-licensen](https://github.com/Tntdruid/ORGPhishingDetectionModule/blob/main/LICENSE).
