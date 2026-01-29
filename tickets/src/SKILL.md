---
name: tickets
version: 0.2.0
description: Manage project tickets via helper scripts - list, create, find, set status. Use when user mentions tickets. Run scripts directly; never search or glob for ticket.md files.
allowed-tools:
  - Read
  - Bash
---

# Ticket Management

## Commands (run directly, do not search)

| Query | Run exactly |
|-------|-------------|
| list / status / open / remaining | `~/.claude/skills/aminnaggar_tickets/scripts/list-tickets.sh <tickets_path> [filter]` |
| find / search | `~/.claude/skills/aminnaggar_tickets/scripts/find-tickets.sh <tickets_path> "query"` |
| set status / mark done | `~/.claude/skills/aminnaggar_tickets/scripts/set-status.sh <tickets_path> <id> <status>` |
| next ticket number | `~/.claude/skills/aminnaggar_tickets/scripts/next-ticket.sh <tickets_path>` |
| skill version | Read SKILL.md frontmatter `version` field |

**Filters**: `draft`, `todo`, `current`, `done`, `open` (not done), `closed` (done)

**Do not search or glob for ticket.md files.** Scripts provide compact output.
Only read individual `ticket.md` files when detailed content is needed (acceptance criteria, notes).

## Finding the Tickets Directory

1. Look for `tickets/` in the current project root
2. If not found, ask the user for the path

## Adding a New Ticket

1. Run: `~/.claude/skills/aminnaggar_tickets/scripts/next-ticket.sh /path/to/tickets`
2. Ask user for title, slug, description
3. Create directory: `{number}_{slug}/`
4. Create `ticket.md` with frontmatter (see [reference.md](reference.md))

## Adding a Sub-Ticket

1. Run: `~/.claude/skills/aminnaggar_tickets/scripts/next-ticket.sh /path/to/tickets <parent_id>`
2. Ask for title, slug, description
3. Create directory: `{parent}{letter}_{slug}/`
4. Set `parent` field to relative path to parent's ticket.md

## Setting Status

Run exactly:
```bash
~/.claude/skills/aminnaggar_tickets/scripts/set-status.sh <tickets_path> <id> <status>
```

Valid statuses: `draft`, `todo`, `current`, `done`

The script automatically manages the `completed` date field.

## Conventions

- Cross-references use **relative paths**: `../006_mock_database/ticket.md`
- IDs are strings: `"007"` for main, `"005a"` for sub-tickets
- **Status values**: `draft`, `todo`, `current`, `done` only
- **Completion field**: `completed` only (not "completed_at", "implemented", etc.)
- Dates: `YYYY-MM-DD`

For ticket format specification, see [reference.md](reference.md).
