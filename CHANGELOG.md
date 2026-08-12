# Changelog

Notable changes to the marketplace catalog, in
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format. Version bumps
to individual plugin entries in `.claude-plugin/marketplace.json` are routine
and are not logged here — the commit is the record. This file is for changes
that affect how the marketplace itself installs or behaves.

## [Unreleased]

### Fixed

**Marketplace install failed for users without a GitHub SSH key.**
`claude plugin marketplace add punt-labs/claude-plugins` clones this repo
**with submodules**. The `.punt-labs/ethos` submodule pointed at
`git@github.com:punt-labs/team.git`, so any user whose machine could not
authenticate to GitHub over SSH hit:

```text
Failed to clone '.punt-labs/ethos' a second time, aborting
```

`punt-labs/team` is public, but SSH auth fails before repo visibility is
consulted. Removed the submodule and `.gitmodules`. An HTTPS URL would have
fixed the auth failure but would still copy 1 MB of internal identity data
onto every consumer's disk. Agents working in this repo now resolve identity
from the global `~/.punt-labs/ethos/identities/`.

**The pinned installer URL served a stale script.** `README.md` pinned the
`curl` one-liner to commit `d7679bd`, but `install.sh` changed afterward in
`2a7e501`, so the advertised installer still printed the `main`-pinned example
URLs that commit removed. Both URLs now pin to `2a7e501`, which is on `main`
and carries the current script.

**README described `install.sh` behavior it never had.** It claimed the script
fetches the catalog, lists plugins, and prints a sha256 checksum. It does none
of those — it checks for `claude` and `git`, then registers the marketplace.
Corrected to match.

### Removed

Plugin-generated local state that was shipping to every consumer via
`~/.claude/plugins/marketplaces/punt-labs/`: `.biff` (team roster, NATS relay
URL), `.punt-labs/ethos.yaml`, `.vox/config.md`, and `.lux/config.md`. These
are now gitignored, along with `.beads/` and `.claude/agents/`, so enabling a
plugin in this checkout cannot reintroduce the leak.

### Added

- `Why This Repo Is Different` section in `CLAUDE.md` recording why the
  org-wide ethos-submodule mandate does not apply to a repo that gets cloned
  onto every user's machine
- `Ethos & Delegation` section in `CLAUDE.md` with worker/evaluator pairings
  for catalog work
