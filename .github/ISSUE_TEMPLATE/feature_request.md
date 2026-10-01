---
name: Feature eller nyt brand
about: Foreslå et nyt brand, en ny regel eller en forbedring af detekteringen
title: ""
labels: "enhancement"
assignees: ""
---

## Problem eller behov

Hvilken brugerfejl, phishing-variant eller administrativ opgave skal løses?

## Forslag

Beskriv den ønskede ændring. Ved et nyt brand må du gerne udfylde:

- Brandnavn:
- Forventet symbol, hvis relevant:
- Relevante keywords:
- Legitime domæner:
- Typisk phishing-kontekst:

## Eksempler

Indsæt anonymiserede eksempler på legitime mails og phishing-mails. Fjern modtageradresser, tracking-links, tokens og andre følsomme oplysninger.

## Falske positiver og sikkerhed

- Hvilke almindelige ord kan give falske positiver?
- Hvilke legitime afsendere eller kampagner skal fortsat fungere?
- Skal URL-match eller spoof-kontrol stadig gælde?

## Acceptkriterier

Beskriv, hvornår ændringen kan betragtes som færdig.

## Validering

- [ ] Jeg har overvejet mindst ét forventet match og én forventet ikke-match.
- [ ] Jeg har overvejet autentificering, trusted senders og spoofing.
- [ ] Jeg har kørt `rspamadm configtest`, hvis ændringen allerede er implementeret.
