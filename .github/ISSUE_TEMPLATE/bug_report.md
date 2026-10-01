---
name: Bug eller falsk positiv
about: Rapporter en fejl, et uventet symbol eller en legitim mail, der bliver markeret
title: ""
labels: "bug"
assignees: ""
---

## Type

- [ ] Falsk positiv: en legitim mail bliver markeret
- [ ] Falsk negativ: en phishing-mail bliver ikke markeret
- [ ] Teknisk fejl eller konfigurationsproblem

## Beskrivelse

Beskriv kort, hvad der sker, og hvorfor resultatet er forkert.

## Forventet resultat

Hvad skulle Rspamd have gjort?

## Faktisk resultat

Indsæt relevante symboler, scores og årsager fra Rspamd. Fjern modtageradresser, tracking-links, tokens og andre følsomme oplysninger.

```text
Eksempel:
ORG_PHISHING_VIAPLAY(8.00) [keywords,context]
```

## Mailens kontekst

- Rspamd-version:
- Berørt symbol eller brand:
- Afsenderdomæne:
- Var mailen autentificeret med SPF, DKIM eller DMARC?
- Indeholder mailen en brand-URL?

## Reproduktion

Beskriv de minimale trin eller vedhæft en anonymiseret testmail.

## Validering

- [ ] Jeg har kørt `rspamadm configtest`.
- [ ] Jeg har fjernet eller anonymiseret personlige oplysninger og hemmeligheder.
- [ ] Jeg har testet mindst én forventet match og én forventet ikke-match.
