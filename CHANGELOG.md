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
with the underlying error and a retry command, the closing banner says the
catalog may be stale, and the script exits `2` (see below).

**`install.sh` mistook a fork for this marketplace.** The registration check
was `marketplace list | grep -q punt-labs`, unanchored against output that
includes a `Source: GitHub (punt-labs/claude-plugins)` line under every entry.
A user who had registered a fork under a different name was told "already
registered"; the follow-on update then failed with "not found", and the bug
above swallowed it — so the marketplace was never registered and the script
still declared success. The check now strips the `❯` decoration and compares
the whole first field to the marketplace name. A failing `list` is reported
rather than hidden.

**`install.sh` took `add`'s word for it.** A successful exit from
`claude plugin marketplace add` was treated as proof of registration, from a
CLI the script otherwise does not trust enough to parse. It now re-lists and
re-checks afterwards, and fails loudly if the marketplace is absent despite the
success exit. This also downgrades any future brittleness in the name detector
from a silent stale catalog to a diagnosable complaint.

**A failed command with no output produced a blank "reason".** Both new error
reports printed the captured output unconditionally, so a command that failed
silently yielded a bare newline where the cause should be — which reads as
truncated output rather than as an absence. Empty output is now named as such,
and the exit status is reported alongside it, so "network down" and "corrupt
local clone" are no longer indistinguishable.

**Outcomes the script could not confirm were reported as success.** Two paths
printed a warning and exited `0`, so `install-all.sh`, a Dockerfile `RUN`, or
any CI step saw success: a stale catalog after a failed update, and — worse — a
registration whose confirming re-list failed, which printed `✓ marketplace
registered` and "ready!" for something it had explicitly failed to establish.
That asymmetry gave the *stronger* claim the *weaker* check. Both now exit `2`,
each with its own banner, and the script header documents all three statuses.
`warn` and `fail` also moved to stderr, so a redirected run no longer separates
the label from its cause, and `fail` is red rather than sharing `warn`'s yellow.

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
picks up the fix was wrong for this data.

Deleting the visible directory is not sufficient either. Git keeps a
submodule's object store in the superproject under `.git/modules/<path>/`,
which an `rm -rf` of the working copy does not touch — the whole history stays
recoverable with `git clone "$M/.git/modules/.punt-labs/ethos" out`, confirmed
against a real install. (`git --git-dir … show` is *not* the command to reach
for once the worktree is gone: the module's `core.worktree` still points at the
deleted directory, so it fails with `cannot chdir`, which reads misleadingly
like the data being absent.)

The README remediation removes the worktree, the object store, and the stale
`[submodule]` config section, then verifies by testing those two paths for
absence. It deliberately does not search for the string `punt-labs`: the
marketplace directory is itself named `punt-labs`, so such a search matches the
directory and everything under it and can never come back empty — a success
condition that cannot be met is worse than none. The wrong-path case aborts
rather than warning, since `rm -rf` on a nonexistent path is also silent.

### Removed

Plugin-generated local state that was shipping to every consumer via
`~/.claude/plugins/marketplaces/punt-labs/`: `.biff` (team roster, NATS relay
URL), `.punt-labs/ethos.yaml`, `.vox/config.md`, and `.lux/config.md`. These
are now gitignored, along with `.beads/` and `.claude/agents/`, so enabling a
plugin in this checkout cannot reintroduce the leak.

### Added

- **`leak-guard` CI job** (`.github/workflows/docs.yml`) — fails the build if a
  submodule is tracked (`.gitmodules` or a mode-160000 gitlink), if any tracked
  file is also matched by `.gitignore`, or if any `@`-import in `CLAUDE.md`
  points somewhere that will not ship. Until now the rule existed only as
  prose, which is how a submodule shipped in the first place. Every check runs
  before the job exits, so one build reports every violation.

  Both of the latter checks are derived rather than enumerated, because a
  hand-maintained list is a second copy of a rule that drifts — the first
  version's list had already fallen out of step with `.gitignore` before it
  merged. Tracked-and-ignored is asked directly of git
  (`git ls-files | git check-ignore --stdin --no-index`; `--no-index` is
  load-bearing, since without it `check-ignore` declines to report tracked
  paths at all and the check silently always passes). The import check tests
  every `@`-import, not one hardcoded prefix, and distinguishes three ways a
  target fails to ship: resolving outside the repository, being untracked, or
  being gitignored.

  **This job must be added to the repository's required status checks.** If
  branch protection pins required checks by name, `leak-guard` passes
  unenforced until it is listed.
- Ignore coverage for `.claude/settings.json`,
  `.github/workflows/biff-notify.yml`, and the three lux window-state files
  (`imgui.ini`, `Lux.ini`, `Lux_*.ini`) — paths the punt-labs plugins write on
  enable, committed in sibling repos today and none of them ignored here.

  Two candidates were deliberately left un-ignored, with the reasoning recorded
  in `.gitignore` so nobody adds them back. `.gitmodules` stays visible: an
  ignore hid it twice over — silent in `git status` locally, and invisible to
  CI, since a checkout materialises only tracked files — while buying nothing,
  because `git submodule add` force-stages it regardless. `.claude/hooks/`
  stays visible because every occupant across the org is portable governance
  shell that a repo may legitimately want to track, and ignoring a path makes
  `git add` skip it without a word. The lux entry is three exact filenames
  rather than `*.ini`, which would silently swallow a future `tox.ini`.
- `Why This Repo Is Different` section in `CLAUDE.md` recording why the
  org-wide ethos-submodule mandate does not apply to a repo that gets cloned
  onto every user's machine, and why running any `<tool> enable` here is
  unsafe — enablement edits the *tracked* `CLAUDE.md`, which no ignore rule
  can protect.
- `Ethos & Delegation` section in `CLAUDE.md` with worker/evaluator pairings
  for catalog work
