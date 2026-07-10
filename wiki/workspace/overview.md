---
type: Workspace
title: BrewUI Workspace Overview
description: Mission, folder layout, Flutter desktop stack, GitHub hosting, and routing for the BrewUI contribution workspace.
tags: [workspace, brewui, setup, flutter, github]
timestamp: 2026-07-10T12:10:00Z
---

# BrewUI Workspace Overview

This workspace is the harness for building **BrewUI** — a cross-platform desktop UI for [Homebrew](https://brew.sh). Hosted at [y0n1/brewui](https://github.com/y0n1/brewui).

## Mission

- Deliver a production-quality Flutter desktop app that wraps Homebrew workflows.
- Work **spec-driven**: requirements live in `docs/specs/` before implementation.
- Track actionable work on [GitHub Issues](https://github.com/y0n1/brewui/issues) — see [GitHub backlog](/workspace/backlog.md).
- Maintain a compounding knowledge base in `wiki/` (this OKF bundle) so context accumulates across sessions.
- Keep the Cursor harness (`.cursor/rules/`, `AGENTS.md`) aligned with what actually works.

## Stack (decided)

| Concern | Choice |
|---------|--------|
| Framework | Flutter |
| Platforms | Desktop only: macOS, Linux, Windows |
| Design approach | Spec-driven (`docs/specs/`) |
| Knowledge format | [OKF v0.1](/references/okf-v0.1.md) |
| Hosting / backlog | GitHub (`y0n1/brewui`) — Issues + labels |

## Folder layout

```plaintext
./
├── AGENTS.md                    ← session start; routing table
├── .cursor/rules/               ← workspace rules (incl. LLM wiki contract)
├── docs/
│   └── specs/                   ← requirements & feature specs (source of truth)
└── wiki/                        ← this OKF bundle
    ├── index.md                 ← catalog (declares okf_version)
    ├── log.md                   ← chronological update log
    ├── raw/                     ← immutable source drops (agents read only)
    ├── workspace/               ← this section
    ├── entities/
    ├── topics/
    └── references/
```

## Key entry points

| Entry point | Purpose |
|------------|---------|
| Workspace `AGENTS.md` (repo root) | Routing table — where to go for any task |
| `docs/specs/AGENTS.md` | How to author and consume specs |
| `.cursor/rules/llm-wiki.mdc` | Wiki maintenance contract |
| [`/index.md`](/index.md) | Wiki catalog — start here when querying |
| [`/workspace/backlog.md`](/workspace/backlog.md) | GitHub Issues backlog conventions |
| [`/references/okf-v0.1.md`](/references/okf-v0.1.md) | OKF conformance target |
| [y0n1/brewui](https://github.com/y0n1/brewui) | Canonical GitHub repository |

## Citations

[1] [Homebrew](https://brew.sh)
[2] [Karpathy LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)
[3] [Open Knowledge Format (OKF) v0.1](/references/okf-v0.1.md)
[4] [y0n1/brewui](https://github.com/y0n1/brewui)
