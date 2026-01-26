---
id: "001"
title: "Reduce context overhead for ticket queries"
description: Claude searches for ticket files instead of using scripts directly, wasting context.
status: done
created: 2026-01-18
completed: 2026-01-18
---

# Reduce context overhead for ticket queries

## Objective

Eliminate unnecessary search/glob steps when answering ticket queries. Claude should run helper scripts directly instead of exploring the filesystem first.

## Problem

Even after adding "Scripts First" guidance, Claude still searches before using scripts:

```
❯ what tickets remain

⏺ Search(pattern: "tickets/**/ticket.md")
  ⎿  Found 17 files

⏺ Bash(for f in ... head -15 "$f" | grep -E "^(id:|title:|status:)")
```

And when asking for the skill version:

```
❯ what is the version of the tickets skill

⏺ Search(pattern: "**/.claude/skills/**")
⏺ Search(pattern: ".claude/**/*")
⏺ Search(pattern: "**/*skill*")
... many more searches before finally finding VERSION
```

## Root Cause Analysis (per Anthropic best practices)

### 1. Description doesn't constrain behavior

The `description` field is critical for skill selection AND behavioral hints. Current description:

```yaml
description: Manage project tickets - create tickets, list status, track dependencies. Use when user mentions adding tickets, checking ticket status, finding tickets, or managing a tickets/ directory.
```

This tells Claude WHEN to trigger but not HOW to behave. Claude's default is to explore.

### 2. Instructions use wrong "degree of freedom"

Anthropic defines three levels:
- **High freedom**: Multiple approaches valid, context-dependent
- **Medium freedom**: Preferred pattern exists, some variation acceptable
- **Low freedom**: "Run exactly this script. Do not modify."

Ticket operations should be **LOW FREEDOM** because:
- Consistency is critical (field names, formats)
- A specific sequence must be followed
- Scripts exist precisely to avoid improvisation

Our current instructions say "ALWAYS use helper scripts" but this is medium-freedom language. Low-freedom looks like:

```markdown
Run exactly this script:
~/.claude/skills/tickets/scripts/list-tickets.sh ./tickets open

Do not search or glob for ticket files.
```

### 3. We offer alternatives

The "Finding Tickets" section says "Or use Grep directly..." - this offers choices when we should mandate one path.

## Proposed Solution

### 1. Update description with behavioral constraint

```yaml
description: Manage project tickets via helper scripts - list, create, find, set status. Use when user mentions tickets. Run scripts directly; never search or glob for ticket.md files.
```

### 2. Restructure SKILL.md with low-freedom commands at top

Immediately after frontmatter:

```markdown
# Ticket Management

## Commands (run directly, do not search)

| Query | Run exactly |
|-------|-------------|
| list tickets / what's open / status | `~/.claude/skills/tickets/scripts/list-tickets.sh <tickets_path> [filter]` |
| find / search for | `~/.claude/skills/tickets/scripts/find-tickets.sh <tickets_path> "query"` |
| mark as done / set status | `~/.claude/skills/tickets/scripts/set-status.sh <tickets_path> <id> <status>` |
| skill version | `cat ~/.claude/skills/tickets/VERSION` |

Filters: `draft`, `todo`, `current`, `done`, `open`, `closed`

Do not glob or search for `ticket.md` files. Scripts provide compact output.
Only read individual ticket.md files when detailed content is needed.
```

### 3. Remove alternatives from later sections

Delete "Or use Grep directly" and similar suggestions.

## Acceptance Criteria

- [ ] Description updated with behavioral constraint
- [ ] SKILL.md restructured with low-freedom command table at top
- [ ] Alternatives removed from Finding Tickets section
- [ ] Version lookup added to command table
- [ ] Test: "what tickets remain" runs list-tickets.sh without prior search
- [ ] Test: "skill version" runs cat VERSION without searching
