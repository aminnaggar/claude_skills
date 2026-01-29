# Context: ADR Skill Design Discussion

This document captures the conversation that led to the ADR skill design.

## The Question

> If I was to implement ADRs in a project that you are the sole manager of (you are writing all the code and running all the tests etc..., operated by me of course). Would these ADRs be helpful? Or would they just drain your context?

## Brutal Assessment of Traditional ADRs for AI Agents

### What ADRs Solve (for humans)
- Human memory fades over weeks/months
- Human teams need shared understanding
- Onboarding new team members
- "Why did we do this?" questions 6 months later

### Why That Doesn't Apply to AI Agents

1. **No forgetting within a session.** Perfect recall of everything discussed.

2. **Between sessions, the codebase IS the memory.** AI can read code faster than prose. A well-structured codebase with decent commit messages tells everything.

3. **Can re-derive rationale in seconds.** Given a codebase, AI can figure out why something was done a certain way without needing a 300-word essay.

4. **Context is precious.** Reading 8 ADRs at 200-400 words = 1,600-3,200 tokens just on meta-documentation. That's context that could be spent understanding actual code.

### When ADRs DO Help AI Agents

- **Accountability**: Human operator needs to understand why AI made certain decisions
- **External constraints**: Things not visible in code (regulatory, business deals, API limitations)
- **Decision reversals**: When a decision superseded a previous approach

## The Solution: Two-Tier System

### Tier 1: One-liners in CLAUDE.md (always loaded)

```markdown
## Key Decisions
- ORM: Drizzle (not Prisma) - see ADR-012
- API: gRPC internally, REST at edge - see ADR-008
- Auth: Custom JWT (not Auth0) - see ADR-015
```

Cost: ~50 tokens. Acts as "tripwires" that remind AI to check before changing something.

### Tier 2: Skill for deeper context (on-demand)

```bash
/adr list          # list all active decisions (id + title only)
/adr search auth   # grep for auth-related ADRs, show summaries
/adr show ADR-015  # full content of specific ADR
```

Cost: Zero until invoked.

### Why Both Tiers Concurrently

- **Tier 1 without Tier 2**: Know there's a decision but can't get details
- **Tier 2 without Tier 1**: Won't know when to invoke the skill

The one-liners are the critical piece. The skill is the backup.

## Key Innovation: Skill Owns CLAUDE.md Section

The skill "consecrates" a header section in CLAUDE.md:
- Scans active ADRs
- Assesses what's consequential enough to surface
- Regenerates the summary section
- Keeps it bounded (10-15 lines max)

ADRs remain the source of truth. CLAUDE.md section is a generated artifact.

A `context-critical: true` field in ADR frontmatter explicitly flags "this one matters for cross-session context."

## When AI Would Use This

- Before suggesting a library/framework change
- When noticing something unconventional and wanting to understand why
- When user says "remember we decided..." and AI needs to catch up
