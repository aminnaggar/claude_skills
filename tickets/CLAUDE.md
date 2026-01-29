# Tickets Skill - Development

Development workspace for the Claude Code tickets skill.

## Repository

git@git.elnaggar.ca:amin/claudeskills_tickets.git

## Project Structure

```
tickets/
├── CLAUDE.md           # This file - dev instructions
├── README.md           # Public-facing docs
├── justfile            # Dev commands
├── tickets/            # This project's own tickets
├── src/                # Deployable skill files
│   ├── SKILL.md        # Main skill definition (triggers, instructions)
│   ├── reference.md    # Ticket format specification
│   └── scripts/        # Helper scripts
│       ├── find-tickets.sh
│       ├── list-tickets.sh
│       ├── next-ticket.sh
│       └── set-status.sh
└── .claude/
    └── settings.local.json
```

## Just Commands

```bash
just install   # Install skill to ~/.claude/skills/aminnaggar_tickets/
just uninstall # Remove skill
```

## About the Skill

A lightweight, file-based ticket management skill that lives alongside project code.

**Philosophy**: Simple over complex - markdown files with YAML frontmatter, git-friendly, no database.

**Status workflow**: `draft` → `todo` → `current` → `done`

**Key features**:
- Auto-numbered tickets (001, 002...) with sub-tickets (005a, 005b...)
- Dependencies and references via relative paths
- Scripts enforce consistency (status values, `completed` field format)
- List filtering: `open` (not done), `closed` (done), or specific status

See `src/SKILL.md` for full skill instructions and `src/reference.md` for the ticket format spec.
