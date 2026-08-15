# Punt Labs Claude Code Plugins

Plugin marketplace for [Punt Labs](https://github.com/punt-labs) projects.

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/punt-labs/claude-plugins/2406e4b/install.sh -o install.sh && [ -s install.sh ] && sh install.sh
```

The URL is pinned to a specific commit. The script checks that `claude`, `git`
and `awk` are present, then registers this marketplace with Claude Code.

Download and run as `&&`-joined steps rather than `curl … | sh`. Piped straight
into a shell, a failed download is indistinguishable from a successful one:
`curl -f` prints nothing to stdout on an HTTP error, `sh` reads the empty input,
and the pipeline exits `0` — you would be told nothing had gone wrong.

Each part earns its place. The `&&` is load-bearing: without it, a failed
download still runs whatever `install.sh` happens to be sitting in the current
directory, which may be an older, differently-pinned copy. `[ -s install.sh ]`
covers the remaining gap — `sh` on an empty file also exits `0` in silence, so
an empty result is checked rather than executed.

There is deliberately no `--remove-on-error`, which would be the neater way to
express that second guard. It requires curl 7.83.0 or newer, and Ubuntu 22.04
LTS ships 7.81.0 while Debian 11 ships 7.74.0 — on both, an unrecognised option
makes curl exit `2` before it fetches anything, so the flag added for safety
would instead mean no install at all on two supported distributions. A portable
test beats a flag the target audience may not have.

<details>
<summary>Manual setup (no curl)</summary>

```bash
claude plugin marketplace add https://github.com/punt-labs/claude-plugins.git
```

</details>

<details>
<summary>Inspect before running</summary>

```bash
curl -fsSL https://raw.githubusercontent.com/punt-labs/claude-plugins/2406e4b/install.sh -o install.sh && [ -s install.sh ] && cat install.sh
```

Read it, then run it as a separate, deliberate step:

```bash
sh install.sh
```

The download uses the same `&&` chain as the Quick Start, for the same reason:
a block that is pasted whole must not run a stale `install.sh` left over in the
current directory when the download fails. Because the run here is a separate
command you type afterwards, read what `cat` prints before running it — if the
download failed, nothing is printed, and that is the signal to stop.

There is deliberately no `shasum` step here. A digest is only worth computing
if there is a published one to compare it against, and this project does not
publish one — the commit SHA in the URL is what pins the content, and GitHub
serves that path immutably. Printing a hash with nothing to check it against
looks like verification without being any.

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

Deleting the visible directory is **not** enough on its own. Git keeps a
submodule's object store in the superproject at `.git/modules/<path>/`, and an
`rm -rf` of the working copy does not touch it. The whole history stays
recoverable from there — `git clone "$M/.git/modules/.punt-labs/ethos" out`
reconstructs every file. All three pieces have to go:

```bash
M=~/.claude/plugins/marketplaces/punt-labs
if [ ! -d "$M" ]; then
  echo "Not at this path — check: ls ~/.claude/plugins/marketplaces/"
else
  rm -rf "$M/.punt-labs" "$M/.git/modules/.punt-labs"
  git -C "$M" config --remove-section 'submodule..punt-labs/ethos' 2>/dev/null
  claude plugin marketplace update punt-labs
  for p in "$M/.punt-labs" "$M/.git/modules/.punt-labs"; do
    [ -e "$p" ] && echo "STILL PRESENT: $p"
  done
  echo "checked — anything printed above is a leftover"
fi
```

The final loop is the verification, and it checks the two named paths by
absence rather than searching for the string `punt-labs`: the marketplace
directory is itself called `punt-labs`, so any such search matches the
directory and everything under it and can never come back empty.

Removing the whole `.punt-labs/` directory rather than just `.punt-labs/ethos`
is deliberate and safe. Its only occupants were the `ethos` submodule and
`ethos.yaml`, both of which this repo stopped tracking, and `.punt-labs/` is
now gitignored here with a CI check that fails the build if anything under it
becomes tracked again. Nothing legitimate can appear there in a future
marketplace clone, so there is nothing narrower worth preserving.

Check the output rather than assuming. `rm -rf` on a path that does not exist
prints nothing and exits `0`, so silence on its own does not distinguish
"cleared" from "wrong path" — which is why the first line aborts instead of
merely warning if the marketplace lives somewhere else.

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
