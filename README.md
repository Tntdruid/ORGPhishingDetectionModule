<p align="center">
  <img src="https://img.shields.io/badge/Rspamd-Brand%20Phishing%20Module-blue?style=for-the-badge&logo=lua&logoColor=white" alt="Rspamd Brand Phishing Module">
</p>

<h1 align="center">ORG Phishing-detekteringsmodul</h1>

<p align="center">
  Avanceret brandbaseret phishing-detektering til Rspamd 4.2.0+<br>
  Understøtter danske og internationale brands, URL-regler, mistænkelig kontekst og afsenderforfalskning.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/version-1.0.0-blue?style=flat-square" alt="Version 1.0.0">
  <img src="https://img.shields.io/badge/Rspamd-4.2.0+-green?style=flat-square" alt="Rspamd 4.2.0+">
  <img src="https://img.shields.io/badge/Lua-5.1-blueviolet?style=flat-square" alt="Lua 5.1">
  <img src="https://img.shields.io/badge/status-production_success-success?style=flat-square" alt="Production success">
  <img src="https://img.shields.io/badge/license-MIT-lightgrey?style=flat-square" alt="MIT License">
</p>

[GitHub-projekt](https://github.com/Tntdruid/ORGPhishingDetectionModule)

Et modulært Lua-regelsæt til Rspamd, der opdager phishing-mails, som udgiver sig for at komme fra kendte organisationer og tjenester.

Filteret kontrollerer meddelelsens indhold, afsenderdata, URL'er, mistænkelig konto- eller betalingskontekst samt udvalgte tegn på forfalskning. Branddefinitionerne holdes adskilt fra detekteringslogikken, så nye brands kan tilføjes uden at ændre matcheren.

## Krav

- Rspamd 4.2.0 eller nyere
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
- `domains`: legitime domæner og underdomæner, der er knyttet til brandet
- `score`: den score, der tildeles, når brandets symbol matcher

Et brandmatch kræver et brand-keyword sammen med mistænkelig kontekst eller en URL, der matcher brandet. Legitime afsenderdomæner whitelistes for det pågældende brand. Godkendte betroede afsendere, der er konfigureret i `org_phishing.lua`, undertrykker kun tekstmatch på tværs af brands; brand-URL'er og tegn på forfalskning kontrolleres stadig. Modulet kontrollerer også:

- forfalskning af visningsnavn
- forfalskning af Reply-To
- undtagelser for godkendte betroede afsendere ved tekstomtale af andre brands

URL- og afsenderdomæner matches uden hensyn til store og små bogstaver. Underdomæner til konfigurerede domæner accepteres, og jokertegn understøttes.

## Registrerede symboler

| Symbol | Formål | Standardscore |
| --- | --- | ---: |
| `ORG_PHISHING` | Hovedsymbol, når et eller flere brandsymboler matcher | 12.0 |
| `ORG_PHISHING_SPOOF` | Ekstra resultat ved opdaget brandforfalskning | 4.0 |
| `ORG_PHISHING_<BRAND>` | Individuelt brandmatch | Se brandfilen |

De individuelle brandsymboler dækker i øjeblikket:

- YouSee
- PostNord
- Coop
- Netflix
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
- Danske Bank
- Nordea
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
- GLS
- DHL
- FedEx
- UPS
- Saxo Bank
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
- Telia
- 3
- Norlys
- Salling Group
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

Sørg for, at symbolnavnet er unikt. Kør `rspamadm configtest`, og genindlæs Rspamd efter ændringer i brandfilen.

## Test

Test altid konfigurationssyntaksen før genindlæsning:

```bash
rspamadm configtest
```

Til funktionstest kan du sende repræsentative testmeddelelser gennem Rspamd og kontrollere de returnerede symboler og scores. Test både mistænkte phishing-mails og legitime meddelelser fra konfigurerede domæner for at kontrollere whitelist-adfærden.

## Bemærkninger

Dette er et heuristisk phishing-regelsæt. Det bør supplere Rspamds indbyggede regler, godkendelseskontroller og omdømmesystemer i stedet for at erstatte dem. Gennemgå matches, og justér scores til dit mailflow, før reglerne bruges som grundlag for automatisk afvisning.

## Licens

Dette projekt udgives under [MIT-licensen](https://github.com/Tntdruid/ORGPhishingDetectionModule/blob/main/LICENSE).
