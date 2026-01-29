# ADR Format Reference

## Directory Structure

```
adrs/
├── .templates/
│   └── ADR.template.md
├── 001-use-drizzle-orm.md
├── 002-grpc-internal-rest-edge.md
└── 003-custom-jwt-auth.md
```

## Filename Convention

Pattern: `{NNN}-{kebab-case-title}.md`

- Three-digit zero-padded number
- Kebab-case title (lowercase, hyphens)
- `.md` extension

Examples:
- `001-use-drizzle-orm.md`
- `012-grpc-internal-rest-edge.md`

## Frontmatter Schema

```yaml
---
# Required fields
id: ADR-003                          # Format: ADR-{NNN}
title: "Short descriptive title"     # 50 chars max
date: 2026-01-28                     # YYYY-MM-DD
status: proposed                     # proposed | accepted | deprecated | superseded

# Supersession (optional)
supersedes: []                       # Array of ADR IDs this replaces
superseded_by: null                  # ADR ID that replaced this, or null

# Categorization (optional)
tags:
  - architecture                     # domain
  - grpc                             # technology
  - gateway                          # component
deciders:
  - Name

# AI context fields
context-critical: false              # true = surface in CLAUDE.md
summary: "ORM: Drizzle for edge compatibility"  # One-liner (required if context-critical)
---
```

## Field Details

### id
- Format: `ADR-{NNN}` where NNN is zero-padded
- Must match filename number
- Example: `ADR-003` for file `003-use-drizzle-orm.md`

### title
- Short, descriptive title
- Maximum 50 characters
- Should describe the decision, not the problem

### date
- ISO format: `YYYY-MM-DD`
- Date the ADR was created or last updated

### status
- `proposed`: Under discussion, not yet accepted
- `accepted`: Active and enforced
- `deprecated`: No longer applies (context changed)
- `superseded`: Replaced by a newer ADR

### supersedes / superseded_by
- `supersedes`: Array of ADR IDs this decision replaces
- `superseded_by`: Single ADR ID that replaced this one
- When superseding, update BOTH the new and old ADRs

### tags
Three categories:
- **component**: Which part of the system (gateway, auth, api)
- **domain**: What kind of decision (architecture, security, performance)
- **technology**: What tech is involved (grpc, kubernetes, python)

### context-critical
- `true`: Surface in CLAUDE.md for cross-session awareness
- `false`: Available on-demand but not loaded automatically

### summary
- One-liner for CLAUDE.md display
- Format: "Domain: Decision"
- Required when `context-critical: true`
- Examples:
  - "ORM: Drizzle over Prisma for edge compatibility"
  - "Auth: Custom JWT, not Auth0"
  - "API: gRPC internal, REST at edge"

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
- Reason 1
- Reason 2
- Reason 3

## Consequences

### Positive
- What we gain

### Negative
- What we sacrifice

### Neutral
- What changes (neither good nor bad)

## Alternatives Considered

### Option A: [Name]
- Why considered
- Why rejected

### Option B: [Name]
- Why considered
- Why rejected

## References
- Related ADRs: ADR-001, ADR-002
- External docs: [link]
```

## Status Lifecycle

```
proposed ──> accepted ──> deprecated
                    └──> superseded (by new ADR)
```

When superseding:
1. Create new ADR with `supersedes: [ADR-XXX]`
2. Update old ADR: `status: superseded`, `superseded_by: ADR-YYY`
