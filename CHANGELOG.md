# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added

- `.punt-labs/ethos/` team submodule pointing at `punt-labs/team` for the org-wide identity registry (gitlink in `.punt-labs/ethos` is the source of truth)
- `Ethos & Delegation` section in `CLAUDE.md` with worker/evaluator pairings for catalog work

### Removed

- `.punt-labs/ethos/config.yaml` (held `active: claude`) — superseded by the new `.punt-labs/ethos` submodule and the existing `.punt-labs/ethos.yaml`

### Changed

- Lux display disabled by default (`.lux/config.md` sets `display: n`) so the visual surface stays off until an agent explicitly enables it
- Vox configured for this repo: `speak: y` (turns text-to-speech on by default), neutral vibe, unique voice within the org so individual agents are distinguishable when speaking. Previous default was `speak: n`.
