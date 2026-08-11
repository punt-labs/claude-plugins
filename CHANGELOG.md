# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Fixed

- **Marketplace install no longer fails for users without a GitHub SSH key.** The `.punt-labs/ethos` submodule pointed at `git@github.com:punt-labs/team.git`. `claude plugin marketplace add` clones this repo with submodules, so the SSH URL aborted the clone (`Failed to clone '.punt-labs/ethos' a second time, aborting`) for anyone whose machine could not authenticate to GitHub over SSH. The submodule and `.gitmodules` are removed.

### Removed

- `.punt-labs/` — the `ethos` team submodule (1 MB, 246 files of internal identities, personalities, and writing styles) and `ethos.yaml`. Agents in this repo now resolve identity from the global `~/.punt-labs/ethos/identities/`.
- `.gitmodules` — this repo carries no submodules by design
- `.biff` — internal team roster and NATS relay URL
- `.vox/config.md` and `.lux/config.md` — per-repo voice and display settings

  All were plugin-generated local state that shipped to every marketplace consumer via `~/.claude/plugins/marketplaces/punt-labs/`.

### Added

- `Why This Repo Is Different` section in `CLAUDE.md` — documents that this repo is cloned onto every user's machine, why the org-wide ethos-submodule mandate does not apply here, and the rule that plugin-generated per-repo state is never committed
- `.gitignore` entries for `.punt-labs/`, `.vox/`, `.lux/`, `.biff`, `.beads/`, and `.claude/agents/` so enabling a plugin in this checkout cannot re-introduce the leak
- `Ethos & Delegation` section in `CLAUDE.md` with worker/evaluator pairings for catalog work
