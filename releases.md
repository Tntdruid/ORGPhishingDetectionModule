# Releases

## Unreleased

- Reworked brand matching to require brand keywords together with suspicious context or a matching brand URL.
- Added an authenticated trusted-sender exception for cross-brand text mentions while retaining URL and spoof detection.
- Removed the broad `nemlig` keyword to avoid matching the ordinary Danish word.
- Added UTF-8-safe word boundaries to reduce short-keyword false positives inside unrelated words.
- Replaced per-brand urgency lists with shared payment, account, login, identity, delivery, and subscription context patterns.
- Added brand definitions for MitID, e-Boks, Digital Post, Danske Bank, Nordea, Nets, PayPal, Elgiganten, Skat, public services, telecom providers, retailers, and additional organisations.
- Updated the README and brand configuration examples to document the new matching behaviour and available brands.
- Documentation and brand definitions continue to evolve.
- Add new organisation definitions in `lua.local.d/org_phishing_brands.lua`.
- Validate configuration with `rspamadm configtest` after changes.

## 0.1.0 - Initial release

- Added modular Rspamd phishing detection in `org_phishing.lua`.
- Added separate brand definitions in `org_phishing_brands.lua`.
- Added keyword, URL, urgency phrase, and sender spoof detection.
- Registered individual brand symbols, `ORG_PHISHING_SPOOF`, and the aggregate `ORG_PHISHING` symbol.
- Added definitions for YouSee, PostNord, Coop, Netflix, MobilePay, EasyPark, Klarna, DAO, GLS, DHL, FedEx, Saxo Bank, Andel Energi, and Bring.
