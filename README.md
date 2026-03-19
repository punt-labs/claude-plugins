# Punt Labs Claude Code Plugins

Plugin marketplace for [Punt Labs](https://github.com/punt-labs) projects.

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/punt-labs/claude-plugins/d7679bd/install.sh | sh
```

The URL is pinned to a specific commit. The script fetches the marketplace
catalog, shows available plugins with source repos, displays a sha256 checksum,
then registers the marketplace with Claude Code.

<details>
<summary>Manual setup (no curl)</summary>

```bash
claude plugin marketplace add punt-labs/claude-plugins
```

</details>

<details>
<summary>Verify before running</summary>

```bash
curl -fsSL https://raw.githubusercontent.com/punt-labs/claude-plugins/d7679bd/install.sh -o install.sh
shasum -a 256 install.sh
cat install.sh
sh install.sh
```

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
