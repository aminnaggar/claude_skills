# ADR Skill - Development

Development workspace for the Claude Code ADR (Architecture Decision Records) skill.

## Project Structure

```
adrs/
├── CLAUDE.md           # This file - dev instructions
├── README.md           # Public-facing docs
├── justfile            # Dev commands
├── tickets/            # This project's own tickets
├── src/                # Deployable skill files
│   ├── SKILL.md        # Main skill definition (triggers, instructions)
│   ├── reference.md    # ADR format specification
│   ├── .templates/
│   │   └── ADR.template.md
│   └── scripts/        # Helper scripts
│       ├── list-adrs.sh
│       ├── show-adr.sh
│       ├── summary-adrs.sh
│       ├── search-adrs.sh
│       ├── sync-claude-md.sh
│       └── next-adr.sh
└── .claude/
    └── settings.local.json
```

## Just Commands

```bash
just install    # Install src/* to ~/.claude/skills/aminnaggar_adrs/
just uninstall  # Remove skill from ~/.claude/skills/aminnaggar_adrs/
```

## About the Skill

A two-tier ADR management skill that balances context efficiency with decision traceability.

**Philosophy**: Full ADRs are valuable for humans but expensive for AI context. This skill surfaces critical decisions as one-liners in CLAUDE.md (Tier 1) while keeping full rationale available on-demand (Tier 2).

**Status workflow**: `proposed` -> `accepted` -> `deprecated`/`superseded`

**Key features**:
- Auto-numbered ADRs (001, 002...) with kebab-case filenames
- `context-critical: true` flag to mark ADRs for CLAUDE.md surfacing
- `/adr sync` regenerates the CLAUDE.md summary section
- Scripts enforce consistency and minimize context consumption
- Compatible with existing ADR format at optiu/newcore

**CLAUDE.md section format**:
```markdown
## ADRs

- ORM: Drizzle over Prisma for edge compatibility - ADR-012
- Auth: Custom JWT, not Auth0 - ADR-015
```

See `src/SKILL.md` for full skill instructions and `src/reference.md` for the ADR format spec.

## Tools Required

- `yq` - for YAML frontmatter parsing
- `rg` (ripgrep) - for content search

## Key Design Decisions

- **Tier 1 + Tier 2 together**: One-liners act as "tripwires" (~50 tokens), skill provides depth on-demand (zero cost until invoked)
- **Skill owns `## ADRs` section**: No HTML markers - Claude edits between `## ADRs` and next `##` or EOF
- **`context-critical` field**: Explicit flag - not every ADR belongs in CLAUDE.md, only non-obvious decisions that would otherwise be contradicted

## ADRs

- Skill ID: Use directory name (aminnaggar_adrs) instead of frontmatter id field - ADR-001
- Versioning: Add version field to SKILL.md frontmatter for discoverability - ADR-002
