---
id: "002"
title: "Modernize justfile and versioning"
description: Align with adrs skill patterns - install/uninstall commands, version in frontmatter, smart feedback.
status: current
created: 2026-01-29
---

# Modernize justfile and versioning

## Objective

Update the tickets skill to use the same patterns as the newer adrs skill for install/uninstall and versioning.

## Context

The adrs skill has better patterns:
- `install`/`uninstall` commands instead of `deploy`
- Version in SKILL.md frontmatter instead of separate VERSION file
- Smart install feedback showing version changes
- Namespaced directory to avoid conflicts

## Acceptance Criteria

- [ ] Move version from VERSION file into SKILL.md frontmatter
- [ ] Delete src/VERSION file
- [ ] Rename `deploy` to `install` in justfile
- [ ] Add `uninstall` command to justfile
- [ ] Add version feedback on install (Updated/Reinstalled/Installed)
- [ ] Namespace the skill directory as `aminnaggar_tickets`
- [ ] Update all script paths in SKILL.md to use new directory

## Notes

Following ADR-002 from adrs skill: version field in skill frontmatter.
