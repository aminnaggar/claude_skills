---
name: adrs
version: 1.0.0
description: Manage Architecture Decision Records with auto-syncing summaries to CLAUDE.md. Use when user discusses architectural decisions, technology choices, or says "/adr".
allowed-tools:
  - Read
  - Edit
  - Write
  - Bash
---

# ADR Management

## Commands

| Command | Script |
|---------|--------|
| `/adr list` | `~/.claude/skills/aminnaggar_adrs/scripts/list-adrs.sh <adr_path>` |
| `/adr list all` | `~/.claude/skills/aminnaggar_adrs/scripts/list-adrs.sh <adr_path> all` |
| `/adr show <id>` | `~/.claude/skills/aminnaggar_adrs/scripts/show-adr.sh <adr_path> <id>` |
| `/adr summary` | `~/.claude/skills/aminnaggar_adrs/scripts/summary-adrs.sh <adr_path>` |
| `/adr search <query>` | `~/.claude/skills/aminnaggar_adrs/scripts/search-adrs.sh <adr_path> "query"` |
| `/adr sync` | `~/.claude/skills/aminnaggar_adrs/scripts/sync-claude-md.sh <adr_path>` then edit CLAUDE.md |
| `/adr new` | See workflow below |

**Filters for list**: `active` (default), `all`, `proposed`, `accepted`, `deprecated`, `superseded`

## Finding the ADRs Directory

1. Look for `adrs/` in the current project root
2. If not found, ask the user for the path

## /adr new - Creating an ADR

**Principle**: Infer everything from conversation context. Only ask user for judgment calls.

### Workflow

1. **Draft the ADR** from conversation context. Fill ALL frontmatter fields:
   - `id`: Run `next-adr.sh` to get next number, format as `ADR-XXX`
   - `title`: Short descriptive title (50 chars max)
   - `date`: Today's date (YYYY-MM-DD)
   - `status`: `proposed` (default for new ADRs)
   - `supersedes`: `[]` initially
   - `superseded_by`: `null`
   - `tags`: Infer from context (component, domain, technology)
   - `deciders`: Include user's name if known
   - `context-critical`: Your best guess (see criteria below)
   - `summary`: One-liner in format "Domain: Decision" (required if context-critical)

2. **Check for conflicts**: Run `summary-adrs.sh` to get all active ADR summaries

3. **Ask user only for judgment calls**:
   - "This might supersede ADR-003 (ORM: Prisma for type safety). Does it?"
   - "Is this context-critical? (Should future sessions see this in CLAUDE.md?)"

4. **Create the file**: `{NNN}-{kebab-case-title}.md` in the adrs directory

5. **If supersedes another ADR**: Update the old ADR's frontmatter:
   - Set `status: superseded`
   - Set `superseded_by: ADR-XXX` (the new ADR's ID)

6. **If context-critical**: Run `/adr sync` to update CLAUDE.md

### Context-Critical Criteria

Set `context-critical: true` when:
- Non-obvious technology/library choice (would Claude suggest differently?)
- Contradicts common conventions or defaults
- Reversing would require significant refactoring
- External constraints not visible in code (regulatory, business, API limitations)

NOT context-critical:
- Standard best practices
- Decisions obvious from reading the code
- Minor implementation details

## /adr sync - Updating CLAUDE.md

1. Run `sync-claude-md.sh <adr_path>` to get the formatted section content
2. Find the `## ADRs` section in the project's CLAUDE.md
3. Replace everything under that header until the next `##` or EOF
4. If no `## ADRs` section exists, add it at the end of the file
5. If no CLAUDE.md exists, create one with the ADRs section

**Do not use HTML markers.** The `## ADRs` header is the boundary.

## ADR File Format

Filename: `{NNN}-{kebab-case-title}.md` (e.g., `003-use-drizzle-orm.md`)

See [reference.md](reference.md) for full format specification.

## Conventions

- IDs: `ADR-001`, `ADR-002`, etc.
- Status lifecycle: `proposed` -> `accepted` -> `deprecated` or `superseded`
- `supersedes` is an array (can replace multiple ADRs)
- `superseded_by` is singular (only one ADR can replace this one)
- Always run scripts via full path: `~/.claude/skills/aminnaggar_adrs/scripts/`
