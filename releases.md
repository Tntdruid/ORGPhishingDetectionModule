# Udgivelser

## Ikke udgivet endnu

- Kommende ændringer tilføjes her.

## 1.0.0 - 21. september 2026

- Omlagt brandmatch, så der kræves brand-keywords sammen med mistænkelig kontekst eller en URL, der matcher brandet.
- Tilføjet en godkendt undtagelse for betroede afsendere ved tekstomtale af andre brands, mens URL- og forfalskningskontrol bevares.
- Fjernet det brede keyword `nemlig` for at undgå match på det almindelige danske ord.
- Tilføjet UTF-8-sikre ordgrænser for at reducere falske positive på korte keywords inde i andre ord.
- Erstattet separate hastelister pr. brand med fælles mønstre for betaling, konto, login, identitet, levering og abonnement.
- Tilføjet branddefinitioner for MitID, e-Boks, Digital Post, Danske Bank, Nordea, Nets, PayPal, Elgiganten, Skat, offentlige tjenester, teleselskaber, detailhandel og flere organisationer.
- Tilføjet en branddefinition for TV 2 Play.
- Tilføjet branddefinitioner for Jyske Bank, Sydbank, Lunar, Tryg, Topdanmark, Alm. Brand, DSB, Rejsekort, Matas, Netto, REMA 1000, OK og Clever.
- Opdateret README og eksempler på brandkonfiguration med den nye matchadfærd og de tilgængelige brands.
- Validér konfigurationen med `rspamadm configtest` efter ændringer.

## 0.1.0 - Første udgivelse

- Tilføjet modulær Rspamd-phishingdetektering i `org_phishing.lua`.
- Tilføjet separate branddefinitioner i `org_phishing_brands.lua`.
- Tilføjet kontrol af keywords, URL'er, hastighedsfraser og afsenderforfalskning.
- Registreret individuelle brandsymboler, `ORG_PHISHING_SPOOF` og det samlede symbol `ORG_PHISHING`.
- Tilføjet definitioner for YouSee, PostNord, Coop, Netflix, MobilePay, EasyPark, Klarna, DAO, GLS, DHL, FedEx, Saxo Bank, Andel Energi og Bring.
