# Agent Instructions

This repo is the Punt Labs plugin marketplace catalog for Claude Code.

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
5. **Take every comment seriously.** Do not dismiss feedback as "unrelated to the change" or "pre-existing." If you disagree, explain why in a reply.
6. **Fix and re-push** — commit fixes, push, re-run quality gates.
7. **Repeat steps 3–6** until the latest review is **uneventful** — zero new comments, all checks green.
8. **Merge only when the last review was clean** — use `mcp__github__merge_pull_request` (not `gh pr merge`).

## Standards References

- [Distribution](https://github.com/punt-labs/punt-kit/blob/main/standards/distribution.md)
- [Plugins](https://github.com/punt-labs/punt-kit/blob/main/standards/plugins.md)
