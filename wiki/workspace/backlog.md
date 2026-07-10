---
type: Workspace
title: GitHub backlog
description: How BrewUI tracks work on GitHub Issues with workflow labels (Projects pending token scope).
tags: [workspace, github, backlog, issues]
timestamp: 2026-07-10T12:10:00Z
---

# GitHub backlog

BrewUI's product backlog lives on GitHub under [y0n1/brewui](https://github.com/y0n1/brewui).

## Source of truth

| Kind of work | Where |
|--------------|-------|
| Backlog / tasks / bugs | [GitHub Issues](https://github.com/y0n1/brewui/issues) |
| Requirements & acceptance criteria | [`docs/specs/`](../../docs/specs/) (link from issues; do not duplicate) |
| Durable learnings | This OKF wiki |

## Workflow labels

| Label | Meaning |
|-------|---------|
| `backlog` | Captured, not yet scheduled |
| `ready` | Ready to pick up |
| `in-progress` | Actively being worked |
| `blocked` | Waiting on a dependency or decision |
| `spec` | Needs or tracks a `docs/specs/` artifact |
| `flutter` | Flutter / desktop platform work |
| `homebrew` | Homebrew CLI / `brew` integration |

Default GitHub labels (`bug`, `enhancement`, `documentation`, …) remain available.

## Agent habits

1. Prefer creating or updating an **Issue** for actionable work instead of only mentioning it in chat.
2. When an issue needs a spec, add the `spec` label and link the eventual `docs/specs/` file in the issue body.
3. Move labels forward (`backlog` → `ready` → `in-progress`) rather than inventing parallel status docs.

## GitHub Projects

A Projects board is desirable for board-style triage. Creating one requires the `project` / `read:project` token scopes:

```bash
gh auth refresh -s project,read:project
gh project create --owner @me --title "BrewUI Backlog"
gh project link <number> --owner @me --repo y0n1/brewui
```

Until that is enabled, **Issues + labels** are the backlog system of record.

## Citations

[1] [y0n1/brewui issues](https://github.com/y0n1/brewui/issues)
[2] [y0n1/brewui repository](https://github.com/y0n1/brewui)
