# Punt Labs Claude Code Plugins

Plugin marketplace for [Punt Labs](https://github.com/punt-labs) projects.

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/punt-labs/claude-plugins/2a7e501/install.sh -o install.sh
sh install.sh
```

The URL is pinned to a specific commit. The script checks that `claude` and
`git` are installed, then registers this marketplace with Claude Code.

Download and run as two steps rather than `curl … | sh`. Piped straight into a
shell, a failed download is indistinguishable from a successful one: `curl -f`
prints nothing to stdout on an HTTP error, `sh` reads the empty input, and the
pipeline exits `0`. You would be told nothing had gone wrong. Downloading first
means a 404 — from a force-pushed history, a deleted repo, or a captive-portal
proxy — fails loudly before anything executes.

<details>
<summary>Manual setup (no curl)</summary>

```bash
claude plugin marketplace add punt-labs/claude-plugins
```

</details>

<details>
<summary>Inspect before running</summary>

```bash
curl -fsSL https://raw.githubusercontent.com/punt-labs/claude-plugins/2a7e501/install.sh -o install.sh
shasum -a 256 install.sh
cat install.sh
sh install.sh
```

</details>

<details>
<summary>Already installed before August 2026? Clear the leftover identity data</summary>

Marketplace clones made before this repo dropped its `ethos` submodule still
carry a copy of the Punt Labs team registry — roughly 1 MB of identity,
personality, and writing-style files — under
`~/.claude/plugins/marketplaces/punt-labs/.punt-labs/`.

Updating does **not** remove it. Git cannot delete a directory that still has
files in it, so the update prints `warning: unable to rmdir '.punt-labs/ethos':
Directory not empty`, exits `0`, and leaves the data on disk indefinitely.

To clear it:

```bash
rm -rf ~/.claude/plugins/marketplaces/punt-labs/.punt-labs
claude plugin marketplace update punt-labs
```

Nothing in it is secret and nothing in it is load-bearing for the marketplace —
it is internal team metadata that should never have shipped.

</details>

## Available Plugins

| Plugin | Source | Description |
|--------|--------|-------------|
| `beadle` | [beadle](https://github.com/punt-labs/beadle) | Autonomous email agent with Proton Bridge and PGP trust model |
| `biff` | [biff](https://github.com/punt-labs/biff) | UNIX-style team communication (`/who`, `/finger`, `/write`, `/read`) |
| `dungeon` | [dungeon](https://github.com/punt-labs/dungeon) | Text adventure game engine for Claude Code |
| `ethos` | [ethos](https://github.com/punt-labs/ethos) | Identity binding for humans and AI agents |
| `lux` | [lux](https://github.com/punt-labs/lux) | Visual output surface --- tables, charts, dashboards, and interactive elements |
| `prfaq` | [prfaq](https://github.com/punt-labs/prfaq) | Amazon Working Backwards PR/FAQ process with LaTeX output |
| `punt` | [punt-kit](https://github.com/punt-labs/punt-kit) | Standards enforcement and reconciliation |
| `quarry` | [quarry](https://github.com/punt-labs/quarry) | Local semantic search with automagic knowledge capture |
| `vox` | [vox](https://github.com/punt-labs/vox) | Voice for your AI coding assistant (`/unmute`, `/speak`, `/recap`, `/vibe`) |
| `z-spec` | [z-spec](https://github.com/punt-labs/z-spec) | Formal Z specifications --- generate, type-check, animate, and derive test cases |
