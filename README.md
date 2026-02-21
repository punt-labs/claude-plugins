# Punt Labs Claude Code Plugins

Plugin marketplace for [Punt Labs](https://github.com/punt-labs) projects.

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/punt-labs/claude-plugins/3ebea28/install.sh | sh
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
curl -fsSL https://raw.githubusercontent.com/punt-labs/claude-plugins/3ebea28/install.sh -o install.sh
shasum -a 256 install.sh
cat install.sh
sh install.sh
```

</details>

## Available Plugins

| Plugin | Source | Description |
|--------|--------|-------------|
| `punt` | [punt-kit](https://github.com/punt-labs/punt-kit) | Standards enforcement and reconciliation |
| `dungeon` | [dungeon](https://github.com/punt-labs/dungeon) | Text adventure game engine for Claude Code |
| `biff` | [biff](https://github.com/punt-labs/biff) | UNIX-style team communication (`/who`, `/finger`, `/write`, `/read`) |
| `prfaq` | [prfaq](https://github.com/punt-labs/prfaq) | Amazon Working Backwards PR/FAQ process with LaTeX output |

## Install a Plugin

```bash
claude plugin install punt@punt-labs
claude plugin install dungeon@punt-labs
claude plugin install biff@punt-labs
claude plugin install prfaq@punt-labs
```

