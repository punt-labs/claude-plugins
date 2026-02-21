# Agent Instructions

This repo is the Punt Labs plugin marketplace catalog for Claude Code.

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

## Standards References

- [Distribution](https://github.com/punt-labs/punt-kit/blob/main/standards/distribution.md)
- [Plugins](https://github.com/punt-labs/punt-kit/blob/main/standards/plugins.md)
