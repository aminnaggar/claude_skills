---
id: "001"
title: "ADR Skill Implementation"
description: A Claude Code skill for managing Architecture Decision Records with auto-syncing summaries to CLAUDE.md
status: done
created: 2026-01-28
references:
  - './context.md'
  - './existing_adr_system.md'
completed: 2026-01-29
---

# ADR Skill Implementation

## Objective

Build a Claude Code skill that manages Architecture Decision Records (ADRs) with a two-tier context system:
1. **Tier 1**: Auto-generated one-liner summaries in a `## ADRs` section in CLAUDE.md (always loaded, ~50 tokens)
2. **Tier 2**: On-demand full ADR access via skill commands (zero cost until invoked)

## Context

See `./context.md` for the full discussion that led to this design.

### The Problem Being Solved

When working across multiple sessions, Claude may:
- Suggest changing libraries/frameworks that were deliberately chosen
- Recommend approaches that contradict past architectural decisions
- "Helpfully" revert decisions without knowing the rationale

ADRs solve this for human teams, but loading full ADRs every session wastes context. This skill creates a tiered system where:
- Critical decisions are surfaced as tripwires in CLAUDE.md
- Full rationale is available on-demand when needed

### Existing ADR System Reference

The skill should be compatible with the ADR format already in use at:
`/Users/amin/Development/optiu/newcore/master/docs/decisions/`

See `./existing_adr_system.md` for format details.

## Acceptance Criteria

### Core Commands

- [ ] `/adr list` - List active ADRs (id + title + status). Active = `proposed` + `accepted`
- [ ] `/adr list all` - List all ADRs including deprecated/superseded
- [ ] `/adr show <id>` - Display full ADR content
- [ ] `/adr summary` - Show all active ADRs with summary field only (for conflict detection)
- [ ] `/adr search <query>` - Search ADRs by content/tags
- [ ] `/adr sync` - Regenerate the CLAUDE.md `## ADRs` section
- [ ] `/adr new` - Create ADR from conversation context (Claude infers fields, asks only for judgment calls)

### CLAUDE.md Integration

- [ ] Skill owns a `## ADRs` section in CLAUDE.md
- [ ] `sync` outputs formatted content, Claude edits CLAUDE.md (no HTML markers)
- [ ] Section is bounded (10-15 lines max)
- [ ] Each line format: `- {summary} - ADR-{id}`
- [ ] Only surfaces `context-critical: true` ADRs
- [ ] If CLAUDE.md doesn't exist, create it with the ADRs section

### ADR Format Support

- [ ] Directory convention: `adrs/` in project root
- [ ] Filename pattern: `{NNN}-{kebab-case-title}.md`
- [ ] Frontmatter fields: `id`, `title`, `date`, `status`, `supersedes`, `superseded_by`, `tags`, `deciders`
- [ ] New field: `context-critical: true|false` to flag ADRs for CLAUDE.md surfacing
- [ ] New field: `summary: "Domain: One-liner decision"` for CLAUDE.md line content
- [ ] Status lifecycle: `proposed` → `accepted` → `deprecated`/`superseded`

### Shell Scripts

- [ ] `list-adrs.sh <adr_path> [filter]` - List ADRs. Filters: `active` (default), `all`, `proposed`, `accepted`, `deprecated`, `superseded`
- [ ] `show-adr.sh <adr_path> <id>` - Output full ADR
- [ ] `summary-adrs.sh <adr_path>` - Output id + summary field for all active ADRs
- [ ] `search-adrs.sh <adr_path> <query>` - Search by content/tags
- [ ] `sync-claude-md.sh <adr_path>` - Output formatted CLAUDE.md section content (Claude handles the edit)
- [ ] `next-adr.sh <adr_path>` - Get next ADR number

### Template

- [ ] ADR template at `adrs/.templates/ADR.template.md`
- [ ] Includes `context-critical` and `summary` fields with guidance

### `/adr new` Workflow

1. Claude drafts ADR from conversation context (fills ALL frontmatter fields - infer, don't ask)
2. Claude runs `summary-adrs.sh` to get active ADR summaries
3. Claude reviews for potential conflicts/supersession
4. Claude asks user only for judgment calls:
   - "This might supersede ADR-003 (ORM: Prisma for type safety). Does it?"
   - "Is this context-critical? (Should future sessions see this in CLAUDE.md?)"
5. User decides
6. Claude creates the ADR with `supersedes: [ADR-XXX]` if applicable
7. Claude updates superseded ADR: `status: superseded`, `superseded_by: ADR-YYY`
8. Claude runs sync to update CLAUDE.md if context-critical

**Key principle**: User provides decisions through conversation, Claude handles all the paperwork.

## Technical Notes

### Tools Available

- `yq` for YAML frontmatter parsing
- `rg` (ripgrep) for content search
- Standard bash utilities

### Determining "Context-Critical"

An ADR should be flagged `context-critical: true` when:
- It involves a non-obvious technology/library choice
- It contradicts common conventions or defaults
- Reversing it would require significant refactoring
- It reflects external constraints not visible in code (regulatory, business, API limitations)

NOT context-critical:
- Standard best practices
- Decisions obvious from reading the code
- Minor implementation details

### CLAUDE.md Section Format

```markdown
## ADRs

- ORM: Drizzle over Prisma for edge compatibility - ADR-012
- API: gRPC internal, REST at edge - ADR-008
- Auth: Custom JWT, not Auth0 - ADR-015
```

No HTML markers. Claude finds the `## ADRs` header and replaces content until the next `##` or EOF.

## Notes

- This skill is designed for AI-managed projects where context efficiency matters
- The existing ADR system at optiu/newcore is well-designed but optimized for human teams
- This adaptation adds the `context-critical` and `summary` fields plus CLAUDE.md sync functionality
- Lineage tracking (supersession chains) deferred - Claude can follow `supersedes`/`superseded_by` manually if needed
