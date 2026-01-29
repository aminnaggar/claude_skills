# Existing ADR System Reference

Location: `/Users/amin/Development/optiu/newcore/master/docs/decisions/`

## Directory Structure

```
docs/decisions/
├── README.md                              # Index with quick links and tables
├── 001-explicit-file-paths-in-tickets.md
├── 003-lightweight-adrs-with-frontmatter.md
├── 004-readmes-only-for-complex-components.md
├── 005-progressive-disclosure-documentation.md
├── 006-obsidian-configured-for-proper-paths.md
├── 007-hub-and-spoke-documentation-model.md
└── 008-documentation-templates.md

.templates/
└── ADR.template.md                        # Template for new ADRs
```

## File Naming Convention

Pattern: `{NNN}-{kebab-case-title}.md`

Examples:
- `001-explicit-file-paths-in-tickets.md`
- `003-lightweight-adrs-with-frontmatter.md`

## Frontmatter Format

```yaml
---
id: ADR-XXX
title: "Short Title (50 chars max)"
date: YYYY-MM-DD
status: proposed  # proposed | accepted | deprecated | superseded
supersedes: []
superseded_by: null
tags:
  - component  # e.g., agentbridge, rl-agents, smart-engines, ui, gateway
  - domain     # e.g., architecture, infrastructure, security, performance
  - technology # e.g., grpc, rest, azure, kubernetes, python, typescript
deciders:
  - Name
---
```

## Body Structure

```markdown
# ADR-XXX: Title

## Context
What's the situation? What problem are we solving?
(3-5 sentences)

## Decision
We will [do X].
(1 sentence - clear, decisive)

## Rationale
Why this decision?
- Reason 1 (technical, business, or organizational)
- Reason 2
- Reason 3

## Consequences

### Positive
- What we gain
- Benefits

### Negative
- What we sacrifice
- Trade-offs we accept

### Neutral
- What changes (neither good nor bad)

## Alternatives Considered

### Option A: [Name]
- Why we considered it
- Why we didn't choose it

### Option B: [Name]
- Why we considered it
- Why we didn't choose it

## References
- Related ADRs: [ADR-001], [ADR-002]
- External docs: [link]
- Discussion: [link to meeting notes, RFC, etc.]
```

## Status Lifecycle

```
proposed → accepted → deprecated
                   ↘ superseded (by new ADR)
```

- `proposed`: Under discussion
- `accepted`: Active and enforced
- `deprecated`: No longer applies (context changed)
- `superseded`: Replaced by a newer ADR (link via `superseded_by`)

## Tagging System

Three tag categories:
1. **component**: Which part of the system (agentbridge, rl-agents, etc.)
2. **domain**: What kind of decision (architecture, security, etc.)
3. **technology**: What tech is involved (grpc, kubernetes, etc.)

## Query Examples

List by status:
```bash
yq '.status' docs/decisions/*.md | sort | uniq -c
```

Find by tag:
```bash
rg -l 'tags:' docs/decisions/ | xargs yq '.tags[]' | sort | uniq -c
```

## Modifications for AI-Managed Projects

The new skill will add:

1. **New frontmatter field**: `context-critical: true|false`
   - Flags ADRs that should be surfaced in CLAUDE.md
   - Default: `false`

2. **Auto-sync to CLAUDE.md**:
   - Skill generates summary section from `context-critical: true` ADRs
   - Human doesn't maintain two places manually

3. **Compact output commands**:
   - Shell scripts optimized for minimal context consumption
   - List shows only id + title, not full content
