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

**`install.sh` reported success when the update failed.** For a user who
already had the marketplace registered — which is every returning user — the
update ran as `… 2>/dev/null || true`. The redirect destroyed the diagnostic
and `|| true` destroyed the exit code, so a failed update (network down, auth
failure, corrupt local clone, disk full) printed "Punt Labs marketplace is
ready!" while leaving a stale catalog in place. The failure is now reported
with the underlying error and a retry command, and the closing banner says the
catalog may be stale. Exit stays `0`: the marketplace is registered and the
user is not stuck.

**`install.sh` mistook a fork for this marketplace.** The registration check
was `marketplace list | grep -q punt-labs`, unanchored against output that
includes a `Source: GitHub (punt-labs/claude-plugins)` line under every entry.
A user who had registered a fork under a different name was told "already
registered"; the follow-on update then failed with "not found", and the bug
above swallowed it — so the marketplace was never registered and the script
still declared success. The check now strips the `❯` decoration and compares
the whole first field to the marketplace name. A failing `list` is reported
rather than hidden.

**`curl … | sh` could not fail.** The documented Quick Start piped the download
straight into a shell. With `curl -f`, an HTTP error prints nothing to stdout,
`sh` reads empty input, and the pipeline exits `0` — a 404 from a force-pushed
history or a captive-portal proxy was indistinguishable from a successful
install. Quick Start now downloads and runs as two steps.

**Existing installs kept the leaked identity data.** Removing the submodule
upstream does not remove it from a consumer's working tree: git cannot delete a
non-empty directory, so `marketplace update` prints `warning: unable to rmdir
'.punt-labs/ethos': Directory not empty`, exits `0`, and leaves ~1 MB of team
registry on disk indefinitely. The previous release's note claiming an update
picks up the fix was wrong for this data. README now carries the `rm -rf` +
update remediation.

### Removed

Plugin-generated local state that was shipping to every consumer via
`~/.claude/plugins/marketplaces/punt-labs/`: `.biff` (team roster, NATS relay
URL), `.punt-labs/ethos.yaml`, `.vox/config.md`, and `.lux/config.md`. These
are now gitignored, along with `.beads/` and `.claude/agents/`, so enabling a
plugin in this checkout cannot reintroduce the leak.

### Added

- **`leak-guard` CI job** (`.github/workflows/docs.yml`) — fails the build if a
  submodule is tracked (`.gitmodules` or a mode-160000 gitlink), if any
  plugin-generated state path is tracked, or if `CLAUDE.md` gains an
  `@.punt-labs/…` import line whose target is gitignored. Until now the rule
  existed only as prose, which is how a submodule shipped in the first place.
  Every check runs before the job exits, so one build reports every violation.

  **This job must be added to the repository's required status checks.** If
  branch protection pins required checks by name, `leak-guard` passes
  unenforced until it is listed.
- Ignore coverage for `.claude/settings.json`, `.claude/hooks/`,
  `.github/workflows/biff-notify.yml`, `.gitmodules`, and `*.ini` — paths the
  punt-labs plugins write on enable, every one of which is committed in sibling
  repos today and none of which were ignored here. Note the `.gitmodules` entry
  is a backstop only: `git submodule add` force-stages it regardless of
  `.gitignore`, so `leak-guard` is the actual enforcement.
- `Why This Repo Is Different` section in `CLAUDE.md` recording why the
  org-wide ethos-submodule mandate does not apply to a repo that gets cloned
  onto every user's machine, and why running any `<tool> enable` here is
  unsafe — enablement edits the *tracked* `CLAUDE.md`, which no ignore rule
  can protect.
- `Ethos & Delegation` section in `CLAUDE.md` with worker/evaluator pairings
  for catalog work
