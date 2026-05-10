# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added

- `beadle` v0.3.0 — autonomous email agent with Proton Bridge and PGP trust model
- `.punt-labs/ethos.yaml` declaring `agent: claude` for this repo
- `.punt-labs/ethos/` team submodule pointing at `punt-labs/team` for org-wide identity registry
- `Ethos & Delegation` section in `CLAUDE.md` with worker/evaluator pairings for catalog work

### Fixed

- `install.sh` — removed example URLs pinned to `main` (violates distribution standard); replaced with pointer to org profile

### Changed

- `beadle` bumped to v0.7.0
- `ethos` bumped to v0.2.0
- Lux display disabled by default (`.lux/config.md` sets `display: n`) so the visual surface stays off until an agent explicitly enables it
- Vox configured with neutral vibe and a unique voice for this repo so individual agents are distinguishable when speaking
