# Releases

## Unreleased

- Documentation and brand definitions continue to evolve.
- Add new organisation definitions in `lua.local.d/org_phishing_brands.lua`.
- Validate configuration with `rspamadm configtest` after changes.

## 0.1.0 - Initial release

- Added modular Rspamd phishing detection in `org_phishing.lua`.
- Added separate brand definitions in `org_phishing_brands.lua`.
- Added keyword, URL, urgency phrase, and sender spoof detection.
- Registered individual brand symbols, `ORG_PHISHING_SPOOF`, and the aggregate `ORG_PHISHING` symbol.
- Added definitions for YouSee, PostNord, Coop, Netflix, MobilePay, EasyPark, Klarna, DAO, GLS, DHL, FedEx, Saxo Bank, Andel Energi, and Bring.
