---
name: changelog-maintenance
description: "Use when adding, reviewing, or finalizing changes that should be reflected in changelog.md or releases.md in this Rspamd project."
---

# Changelog Maintenance

Keep the project changelog current whenever a user-visible behavior, configuration, brand definition, validation workflow, or release milestone changes.

## Project files

- `changelog.md` is the working changelog. Put unreleased changes under `## Ikke udgivet endnu` at the top.
- `releases.md` is the release history. It contains the finalized notes for released versions and may also contain a small unreleased section.
- `README.md` documents supported behavior, installation, symbols, brands, and validation. Update it when the change affects those documented contracts.

## When to update

Update the changelog for changes such as:

- new, removed, or materially changed brand definitions
- changed matching, URL, spoof, trusted-sender, score, or false-positive behavior
- changed symbols, configuration, installation, or validation requirements
- fixes that affect users or administrators
- release preparation or publication

Do not add entries for formatting-only edits, internal investigation, or a test that does not change behavior.

## Workflow

1. Inspect the diff and identify the user-visible effect.
2. Add one concise Danish bullet to `changelog.md` under the existing `## Ikke udgivet endnu` section. Preserve the current order and wording style; do not create a second unreleased section.
3. Avoid duplicate bullets. If an existing item describes the same change, refine it instead of adding another entry.
4. Describe the effect, not implementation noise. Mention the affected brand, symbol, score, or validation command when that is useful to an administrator.
5. Keep bullets factual and short. Use backticks for code, symbols, filenames, domains, and commands.
6. When preparing a release, move the finalized unreleased bullets into a new version section in both files, using the project's date format: `DD. monthname ÅÅÅÅ`.
7. Keep `changelog.md` and `releases.md` semantically synchronized. The files may have different section order, but released notes must not contradict each other.
8. Update `README.md` when the change affects documented brands, symbols, supported behavior, installation, or validation.

## Writing style

- Write in Danish, using the existing past-tense style: `Tilføjet`, `Forbedret`, `Opdateret`, `Fjernet`, `Justeret`, or `Dokumenteret`.
- Prefer one behavior per bullet.
- Name concrete scope instead of vague phrases such as “diverse forbedringer”.
- Do not include raw email contents, tracking URLs, recipient addresses, or sensitive data in changelog entries.
- Treat a reported email as evidence for a rule change, not as a changelog item by itself.

## Release checklist

Before considering a release note complete:

- `changelog.md` has no stale duplicate or empty unreleased entry.
- `releases.md` contains the finalized version and date.
- `README.md` reflects any changed public behavior or configuration.
- The validation command and relevant tests have been run, or the missing environment is stated clearly.
- The final diff contains only the intended documentation changes.

## Validation

Review the relevant diff and search both changelog files for duplicate or contradictory entries. For Rspamd rule changes, run:

```bash
rspamadm configtest
```

For behavior changes, also test at least one expected match and one expected non-match. If Rspamd is unavailable, perform the available Lua or syntax checks and state that full validation still requires a Rspamd host.
