# Agent Instructions

This repo is the Punt Labs plugin marketplace catalog for Claude Code.

## No "Pre-existing" Excuse

There is no such thing as a "pre-existing" issue. If you see a problem — in code you wrote, code a reviewer flagged, or code you happen to be reading — you fix it. Do not classify issues as "pre-existing" to justify ignoring them. Do not suggest that something is "outside the scope of this change." If it is broken and you can see it, it is your problem now.

## Scratch Files

Use `.tmp/` at the project root for scratch and temporary files — never `/tmp`. The `TMPDIR` environment variable is set via `.envrc` so that `tempfile` and subprocesses automatically use it. Contents are gitignored; only `.gitkeep` is tracked.

## Quality Gates

```bash
npx markdownlint-cli2 "**/*.md" "#node_modules"
```

## Structure

- `.claude-plugin/marketplace.json` — marketplace catalog (plugins, versions, sources)
- `install.sh` — one-command marketplace registration script
- `README.md` — plugin listing and install instructions

## Key Rules

- install.sh must be POSIX sh (`#!/bin/sh`)
- curl URLs in README must use commit SHAs, not branch names
- Bump catalog version when updating plugin entries
- Plugin source URLs point to GitHub repos (cloned by Claude Code on install)

## Documentation Discipline

### CHANGELOG

Entries are written **in the PR branch, before merge** — not retroactively on main. If a PR changes user-facing behavior and the diff does not include a CHANGELOG entry, the PR is not ready to merge. Follow [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format. Add entries under `## [Unreleased]`. Categories: Added, Changed, Deprecated, Removed, Fixed, Security.

### README

Update `README.md` when user-facing behavior changes — new plugins added to the catalog, changed catalog structure, or onboarding instructions.

## Code Review Flow

Do **not** merge immediately after creating a PR. Expect **2–6 review cycles** before merging.

1. **Create PR** — push branch, open PR via `mcp__github__create_pull_request`. Prefer MCP GitHub tools over `gh` CLI.
2. **Request Copilot review** — use `mcp__github__request_copilot_review`.
3. **Watch for feedback in the background** — `gh pr checks <number> --watch` in a background task or separate session. Do not stop waiting. Copilot and Bugbot may take 1–3 minutes after CI completes.
4. **Read all feedback** via MCP: `mcp__github__pull_request_read` with `get_reviews` and `get_review_comments`.
5. **Take every comment seriously.** There is no such thing as "pre-existing" or "unrelated to this change" — if you can see it, you own it. If you disagree, explain why in a reply.
6. **Fix and re-push** — commit fixes, push, re-run quality gates.
7. **Repeat steps 3–6** until the latest review is **uneventful** — zero new comments, all checks green.
8. **Merge only when the last review was clean** — use `mcp__github__merge_pull_request` (not `gh pr merge`).

## Ethos & Delegation

This repo is the marketplace catalog. Most edits are direct: bump a version in `marketplace.json`, update `README.md`, regenerate `install.sh` SHA pins. The work is small, mechanical, and rarely benefits from a multi-stage pipeline. The review pairing still matters — a release-distribution change that breaks `install.sh` invalidates every consumer.

**Identity** — `agent: claude` per `.punt-labs/ethos.yaml`. Claude (the leader) is never the evaluator; pair every change with a specialist below.

| Task type | Worker | Evaluator |
|-----------|--------|-----------|
| Marketplace entry add / version bump | `claude` (leader, direct) | `adb` (Lovelace) — release/CI awareness |
| `install.sh` change | `claude` (leader, direct) | `mdm` (McIlroy) — POSIX sh + pipe correctness |
| README / catalog onboarding text | `claude` (leader, direct) | `claudia` (Massimo) — editorial |
| New plugin entry that introduces a new install path | `claude` (leader) | `kth` (Hightower) — infra/CI |
| Org-policy change to plugin distribution | `claude` (leader) | `mcg` (Cagan) — product strategy |

Worker and evaluator must be distinct handles with no shared role. Use the `docs` pipeline for catalog-only changes; otherwise direct dispatch is fine. The full org roster is available via `ethos identity list` if cross-domain review is warranted (e.g., a plugin that surfaces ML or formal-methods features may want `kpz`/`ylc` or `jms`/`jra` review of its README claims).

## Standards References

- [Distribution](https://github.com/punt-labs/punt-kit/blob/main/standards/distribution.md)
- [Plugins](https://github.com/punt-labs/punt-kit/blob/main/standards/plugins.md)
