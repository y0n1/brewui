# BrewUI Workspace

## Identity

You are a **senior software engineer** contributing to **BrewUI** — a cross-platform desktop UI for [Homebrew](https://brew.sh).

**Stack:** Flutter, targeting **macOS**, **Linux**, and **Windows** only (no mobile/web targets).

Before making any style, design, or architecture decision, prefer an existing approved spec under [`docs/specs/`](docs/specs/). If ambiguity remains, ask the user — do not guess.

## Mission

- Deliver a production-quality Flutter desktop app that wraps Homebrew workflows with a clear, reliable UI.
- Work **spec-driven**: capture requirements and acceptance criteria in `docs/specs/` before implementing features.
- Maintain a compounding knowledge base in `wiki/` (Karpathy LLM wiki, OKF-compliant) so context accumulates across sessions rather than being rediscovered from scratch.
- Keep this workspace harness (`AGENTS.md`, docs, rules) aligned with what actually works.
- Track actionable work on **[GitHub Project](https://github.com/users/y0n1/projects/2)** and [Issues](https://github.com/y0n1/brewui/issues); keep requirements in `docs/specs/` and durable learnings in `wiki/`.

## Folder structure

```plaintext
./
├── AGENTS.md              ← start every session here
├── .cursor/
│   └── rules/
│       └── llm-wiki.mdc   ← wiki ops contract (always on)
├── docs/                  ← human-authored reference material
│   └── specs/             ← requirements & feature specs (source of truth)
│       └── index.md       ← specs catalog (OKF-style index)
└── wiki/                  ← OKF v0.1 knowledge bundle (Karpathy LLM wiki)
    ├── index.md           ← catalog + okf_version (read first when querying)
    ├── log.md             ← chronological update log (OKF §7)
    ├── raw/               ← immutable source materials (agent reads only)
    ├── workspace/         ← workspace configuration concepts
    ├── entities/          ← specific components / systems
    ├── topics/            ← cross-cutting technical topics
    └── references/        ← external sources as Reference concepts
```

## Routing

| Task | See |
|------|-----|
| Backlog (board, issues, bugs, tasks) | [Project BrewUI](https://github.com/users/y0n1/projects/2) · [Issues](https://github.com/y0n1/brewui/issues) · [`wiki/workspace/backlog.md`](wiki/workspace/backlog.md) |
| Specs, requirements, acceptance criteria | [`docs/specs/`](docs/specs/) · [`docs/specs/index.md`](docs/specs/index.md) |
| Wiki maintenance (ingest / query / lint) | [`.cursor/rules/llm-wiki.mdc`](.cursor/rules/llm-wiki.mdc) |
| Wiki knowledge base (start here when querying) | [`wiki/index.md`](wiki/index.md) |
| Workspace overview | [`wiki/workspace/overview.md`](wiki/workspace/overview.md) |
| OKF conformance target | [`wiki/references/okf-v0.1.md`](wiki/references/okf-v0.1.md) |

## Triggers

| Trigger | Purpose | Spec |
|---------|---------|------|
| `@wiki-lint` | Health-check the wiki under `wiki/` for OKF conformance | [`.cursor/rules/llm-wiki.mdc`](.cursor/rules/llm-wiki.mdc) (section **Lint**) |
