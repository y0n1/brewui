# Specs

Spec-driven design artifacts for BrewUI. Specs are the **source of truth** for scope and acceptance criteria — implement against them; do not invent requirements in code.

The [`wiki/`](../../wiki/) is the agent-maintained knowledge base (learnings, constraints, synthesis). Do not duplicate approved requirements into the wiki — link to the spec instead.

## Purpose

- Capture product and technical requirements before implementation.
- Define acceptance criteria agents and humans can verify.
- Keep feature intent durable across sessions.

## Conventions

- One feature (or coherent capability) per spec file unless a parent index is needed.
- Prefer concrete, testable acceptance criteria over vague goals.
- When implementation diverges from a spec, update the spec first (or with the change) — do not leave code as the only record of intent.
- Link related specs rather than duplicating requirements.

## Layout

```plaintext
docs/specs/
├── AGENTS.md          ← you are here
└── (feature specs TBD)
```

## Routing

| Task | See |
|------|-----|
| Workspace orientation | [`../../AGENTS.md`](../../AGENTS.md) |
| Wiki catalog | [`../../wiki/index.md`](../../wiki/index.md) |
| Feature specs | files in this directory |
