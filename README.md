<p align="center">
  <img src="https://img.shields.io/badge/Rspamd-Brand%20Phishing%20Module-blue?style=for-the-badge&logo=lua&logoColor=white" alt="Rspamd Brand Phishing Module">
</p>

<h1 align="center">ORG Phishing Detection Module</h1>

<p align="center">
  Advanced brand-based phishing detection for Rspamd 4.2.0+<br>
  Supports Danish and international brands, URL heuristics, suspicious context, and sender spoof detection.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/version-1.0.0-blue?style=flat-square" alt="Version 1.0.0">
  <img src="https://img.shields.io/badge/Rspamd-4.2.0+-green?style=flat-square" alt="Rspamd 4.2.0+">
  <img src="https://img.shields.io/badge/Lua-5.1-blueviolet?style=flat-square" alt="Lua 5.1">
  <img src="https://img.shields.io/badge/status-production_success-success?style=flat-square" alt="Production success">
  <img src="https://img.shields.io/badge/license-MIT-lightgrey?style=flat-square" alt="MIT License">
</p>

[GitHub repository](https://github.com/Tntdruid/ORGPhishingDetectionModule)

A modular Rspamd Lua rule set for detecting phishing messages that impersonate known organisations and services.

The filter checks message content, sender data, URLs, suspicious account or payment context, and selected spoofing indicators. Brand definitions are kept separate from the detection logic, so new brands can be added without changing the matcher.

## Requirements

- Rspamd 4.2.0 or newer
- A Rspamd installation with access to the local Lua configuration directory

The module uses the Rspamd task API and expects `lua.local.d` to be available below the local configuration directory.

## Installation

Copy both Lua files into Rspamd's `lua.local.d` directory:

```text
lua.local.d/org_phishing.lua
lua.local.d/org_phishing_brands.lua
```

For a standard installation, the destination is commonly one of:

```text
/etc/rspamd/lua.local.d/
/usr/local/etc/rspamd/lua.local.d/
```

Then validate and reload Rspamd:

```bash
rspamadm configtest
systemctl reload rspamd
```

Use the equivalent reload command for your platform if Rspamd is managed differently.

## Detection behaviour

Each brand can define:

- `keywords`: names and phrases found in the subject, headers, or text body
- `domains`: legitimate domains and subdomains associated with the brand
- `score`: the score assigned when the brand symbol matches

A brand match requires a brand keyword together with suspicious context or a matching brand URL. Legitimate sender domains are whitelisted for that brand. The module also checks for:

- display-name spoofing
- Reply-To spoofing
- DKIM-authenticated mail from a domain outside the brand's legitimate domain list

URL and sender domains are matched case-insensitively. Subdomains of configured domains are accepted, and wildcard patterns are supported.

## Registered symbols

| Symbol | Purpose | Default score |
| --- | --- | ---: |
| `ORG_PHISHING` | Master symbol when one or more brand symbols match | 12.0 |
| `ORG_PHISHING_SPOOF` | Additional result for a detected brand spoof | 4.0 |
| `ORG_PHISHING_<BRAND>` | Individual brand match | See brand file |

The individual brand symbols currently cover:

- YouSee
- PostNord
- Coop
- Netflix
- MobilePay
- MitID
- e-Boks
- Digital Post
- Danske Bank
- Nordea
- Nets
- PayPal
- EasyPark
- Klarna
- DAO
- GLS
- DHL
- FedEx
- Saxo Bank
- Andel Energi
- Elgiganten
- Skat
- Sygeforsikringen danmark
- borger.dk
- Sundhed.dk
- Udbetaling Danmark
- Telenor
- Telia
- 3
- Norlys
- Salling Group
- Bilka
- føtex
- Lidl
- Power
- Nemlig.com
- Bring

## Adding a brand

Edit `lua.local.d/org_phishing_brands.lua` and add a new entry following the existing structure:

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

Keep the symbol name unique. After changing the brand file, run `rspamadm configtest` and reload Rspamd.

## Testing

Always test configuration syntax before reloading:

```bash
rspamadm configtest
```

For behavioural testing, send representative test messages through Rspamd and inspect the returned symbols and scores. Test both suspected phishing messages and legitimate messages from configured domains to verify the whitelist behaviour.

## Notes

This is a heuristic phishing rule set. It should complement Rspamd's built-in rules, authentication checks, and reputation systems rather than replace them. Review matches and tune scores for your mail flow before using the rules as an automatic rejection criterion.

## License

This project is released under the [MIT License](https://github.com/Tntdruid/ORGPhishingDetectionModule/blob/main/LICENSE).
