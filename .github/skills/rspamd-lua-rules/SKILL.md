---
name: rspamd-lua-rules
description: "Use when adding, modifying, reviewing, or validating Rspamd Lua phishing rules, brand definitions, sender spoofing checks, URL matching, or trusted-sender exceptions in this project."
---

# Rspamd Lua Rules

Use this skill for changes to the local Rspamd phishing module.

## Project structure

- `lua.local.d/org_phishing.lua` contains matching logic, context checks, URL handling, spoof detection, trusted senders, and symbol registration.
- `lua.local.d/org_phishing_brands.lua` contains brand data: symbols, scores, keywords, and legitimate domains.
- `README.md` documents supported Rspamd and Lua versions, installation, symbols, and validation.

## Workflow

1. Identify whether the request changes detection behavior or only brand data.
2. For a new or updated brand, prefer `org_phishing_brands.lua`. Do not duplicate brand-specific logic in `org_phishing.lua` unless the matching behavior itself must change.
3. Preserve the existing brand shape:
   - unique table key
   - unique `ORG_PHISHING_<BRAND>` symbol
   - numeric score
   - focused keywords
   - legitimate domains and required subdomains
4. Treat legitimate sender domains as allowlisted only for the matching brand. Do not broaden trusted-sender exceptions without a clear authentication condition.
5. Keep matching case-insensitive and preserve support for subdomains and configured wildcard patterns.
6. Consider both positive and negative cases before changing scores or matching conditions:
   - a phishing message with the brand name and suspicious context
   - a brand URL combined with the brand name
   - a legitimate message from the configured brand domain
   - a display-name or Reply-To spoof
   - a trusted, authenticated sender mentioning another brand
7. Keep symbol names, scores, and reason strings compatible with the README and existing rules.

## Safety and review rules

- Do not whitelist a domain merely because it appears in a phishing sample; verify that it is an owned, legitimate sender domain.
- Avoid short or generic keywords that can create broad false positives.
- Do not remove spoof checks, URL checks, or authentication requirements to make one sample pass.
- Prefer the smallest change that addresses the reported behavior.
- Do not change unrelated brands or reformat the complete brand table.
- Update `README.md` when adding a brand, changing a symbol, changing supported behavior, or changing the validation workflow.

## Validation

Run the following from a host with Rspamd installed:

```bash
rspamadm configtest
```

For behavior changes, process representative messages through Rspamd and verify returned symbols, scores, and reasons. Test at least one expected match and one expected non-match. For sender or domain changes, include both an authenticated legitimate sender and an unauthenticated spoof.

If Rspamd is unavailable in the development environment, perform a Lua syntax check where possible and state that full `rspamadm configtest` validation still needs to be run on a Rspamd host.
