---
type: Workspace
title: GitHub backlog
description: How BrewUI tracks work via GitHub Project #2, Issues, and workflow labels.
tags: [workspace, github, backlog, issues, projects]
timestamp: 2026-07-10T12:35:00Z
---

# GitHub backlog

BrewUI is managed from the GitHub Project board **[BrewUI (project #2)](https://github.com/users/y0n1/projects/2)**. Issues live in [y0n1/brewui](https://github.com/y0n1/brewui).

## Source of truth

| Kind of work | Where |
|--------------|-------|
| Board / triage / status | [github.com/users/y0n1/projects/2](https://github.com/users/y0n1/projects/2) |
| Backlog items (issues, bugs, tasks) | [GitHub Issues](https://github.com/y0n1/brewui/issues) (also on the Project) |
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

Default GitHub labels (`bug`, `enhancement`, `documentation`, …) remain available. Prefer Project column/status for board state when it conflicts with labels.

## Agent habits

1. Prefer creating or updating an **Issue** for actionable work instead of only mentioning it in chat.
2. Add new issues to [Project #2](https://github.com/users/y0n1/projects/2) (via UI or `gh project item-add` when the token has `project` scope).
3. When an issue needs a spec, add the `spec` label and link the eventual `docs/specs/` file in the issue body.
4. Keep Project status and labels aligned (`backlog` → `ready` → `in-progress`).

## CLI note

`gh project` commands need token scopes `project` and `read:project`:

```bash
gh auth refresh -s project,read:project
gh project item-add 2 --owner @me --url <issue-url>
```

## Citations

[1] [BrewUI Project #2](https://github.com/users/y0n1/projects/2)
[2] [y0n1/brewui issues](https://github.com/y0n1/brewui/issues)
[3] [y0n1/brewui repository](https://github.com/y0n1/brewui)
