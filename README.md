# Punt Labs Claude Code Plugins

Plugin marketplace for [Punt Labs](https://github.com/punt-labs) projects.

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/punt-labs/claude-plugins/main/install.sh | sh
```

The script fetches the marketplace catalog, shows what plugins are available
(with source repos), displays a sha256 checksum for verification, then
registers the marketplace with Claude Code. No files are modified until you
confirm the source is what you expect.

<details>
<summary>Manual setup (no curl)</summary>

```bash
claude plugin marketplace add punt-labs/claude-plugins
```

</details>

## Available Plugins

| Plugin | Source | Description |
|--------|--------|-------------|
| `punt` | [punt-kit](https://github.com/punt-labs/punt-kit) | Standards enforcement and reconciliation |
| `dungeon` | [dungeon](https://github.com/punt-labs/dungeon) | Text adventure game engine for Claude Code |
| `biff` | [biff](https://github.com/punt-labs/biff) | UNIX-style team communication (`/who`, `/finger`, `/write`, `/read`) |

## Install a Plugin

```bash
claude plugin install punt@punt-labs
claude plugin install dungeon@punt-labs
claude plugin install biff@punt-labs
```

## Verify the Install Script

Before piping to `sh`, you can download and inspect:

```bash
curl -fsSL https://raw.githubusercontent.com/punt-labs/claude-plugins/main/install.sh -o install.sh
shasum -a 256 install.sh
# Expected: c6035e237479904377a7d99096c9ba7fb7e2871499b858b009302a050b240b09
cat install.sh
sh install.sh
```
