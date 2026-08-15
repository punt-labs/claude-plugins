#!/bin/sh
# Register the Punt Labs marketplace for Claude Code plugins.
#
# For the install command, see the Quick Start in README.md. It is deliberately
# not repeated here: it carries a commit SHA, and a copy in this file would go
# stale the moment this file changed — which is precisely the bug that shipped
# once already (README pinned a SHA predating the fix it was meant to deliver).
# One pinned URL, in one place.
#
# Exit status:
#   0  the marketplace is registered and current, both confirmed
#   1  this script could not register the marketplace
#   2  the state could not be established. Three ways in: `add` reported
#      success but the listing that would confirm it could not be read;
#      `add` failed while the listing left it unknown whether the
#      marketplace was already there; or an already-registered marketplace
#      could not be updated, so its catalog may be stale
set -eu

# --- Colors (disabled unless both streams are terminals) ---
if [ -t 1 ] && [ -t 2 ]; then
  BOLD='\033[1m' GREEN='\033[32m' YELLOW='\033[33m' RED='\033[31m' NC='\033[0m'
else
  BOLD='' GREEN='' YELLOW='' RED='' NC=''
fi

info() { printf '%b▶%b %s\n' "$BOLD" "$NC" "$1"; }
ok()   { printf '  %b✓%b %s\n' "$GREEN" "$NC" "$1"; }
warn() { printf '  %b!%b %s\n' "$YELLOW" "$NC" "$1" >&2; }
fail() { printf '  %b✗%b %s\n' "$RED" "$NC" "$1" >&2; exit 1; }

# Print a failed command's output, or a placeholder when it printed none —
# a bare newline reads as truncated output rather than as silence.
why() {
  if [ -n "$1" ]; then
    printf '%s\n' "$1" >&2
  else
    printf '    (the command printed nothing)\n' >&2
  fi
}

# Exit 0 if the marketplace listing on stdin names $1. A name is its own line,
# decorated: "  ❯ punt-labs". Strip the decoration and compare the first field,
# so a fork registered under another name is not matched by its
# "Source: ... (punt-labs/claude-plugins)" line.
listed() {
  awk -v name="$1" '{ sub(/^[^[:alnum:]]+/, "") } $1 == name { found = 1 } END { exit !found }'
}

# Register by explicit HTTPS URL, not the "owner/repo" shorthand. The shorthand's
# clone transport is resolved by the CLI and has varied by version; an https://
# URL pins it to HTTPS, which clones a public repo with no SSH key and no GitHub
# authentication. The marketplace's registered name still comes from
# marketplace.json, so the name-matching in listed() is unaffected by which form
# we add — MARKETPLACE_NAME, not the source string, drives every list/update.
MARKETPLACE_GIT="https://github.com/punt-labs/claude-plugins.git"
MARKETPLACE_NAME="punt-labs"

# --- Step 1: Prerequisites ---

info "Checking prerequisites..."

if command -v claude >/dev/null 2>&1; then
  ok "claude CLI found"
else
  fail "'claude' CLI not found. Install Claude Code first: https://docs.anthropic.com/en/docs/claude-code"
fi

if command -v git >/dev/null 2>&1; then
  ok "git found"
else
  fail "'git' not found. Install git first: https://git-scm.com/downloads"
fi

# listed() is written in awk, and an awk that cannot run it reports every
# marketplace as absent — indistinguishable from one that really is. mawk
# 1.3.3, the default awk on older Debian and Ubuntu, has no [[:alnum:]] and
# fails exactly that way. Presence is not enough; ask listed() a question
# whose answer is known.
if ! command -v awk >/dev/null 2>&1; then
  fail "'awk' not found. It reads the marketplace listing; install gawk, mawk, or busybox awk"
elif printf '  ❯ %s\n' "$MARKETPLACE_NAME" | listed "$MARKETPLACE_NAME"; then
  ok "awk found"
else
  fail "'awk' cannot parse a marketplace listing (needs POSIX character classes); install gawk, mawk 1.3.4 or newer, or busybox awk"
fi

# --- Step 2: Register marketplace ---

info "Registering Punt Labs marketplace..."

# Empty CAVEAT means "ready". Otherwise it holds the rest of the closing
# banner's first sentence, and is the reason this script exits 2. Set NEXT
# with it: the one command that resolves that caveat.
CAVEAT=''
NEXT=''
REGISTERED=''
UNKNOWN=''

LISTING=$(claude plugin marketplace list < /dev/null 2>&1) && LIST_RC=0 || LIST_RC=$?

if [ "$LIST_RC" -eq 0 ]; then
  if printf '%s\n' "$LISTING" | listed "$MARKETPLACE_NAME"; then
    REGISTERED=yes
  fi
else
  UNKNOWN=yes
  warn "could not list marketplaces (exit $LIST_RC); trying to register '$MARKETPLACE_NAME' anyway"
  why "$LISTING"
fi

if [ -n "$REGISTERED" ]; then
  ok "marketplace already registered"
  UPDATE_OUT=$(claude plugin marketplace update "$MARKETPLACE_NAME" < /dev/null 2>&1) &&
    UPDATE_RC=0 || UPDATE_RC=$?
  if [ "$UPDATE_RC" -eq 0 ]; then
    ok "marketplace updated"
  else
    CAVEAT='is registered, but the catalog may be stale.'
    NEXT="claude plugin marketplace update $MARKETPLACE_NAME"
    warn "update failed (exit $UPDATE_RC); the local catalog may be stale"
    why "$UPDATE_OUT"
    warn "retry with: claude plugin marketplace update $MARKETPLACE_NAME"
  fi
elif claude plugin marketplace add "$MARKETPLACE_GIT" < /dev/null; then
  # `add` exiting 0 is a claim, not proof. Confirm the name is in the listing.
  VERIFY=$(claude plugin marketplace list < /dev/null 2>&1) && VERIFY_RC=0 || VERIFY_RC=$?
  if [ "$VERIFY_RC" -ne 0 ]; then
    CAVEAT='registration was reported, but could not be confirmed.'
    NEXT="claude plugin marketplace list"
    warn "'add' reported success, but the confirming re-list failed (exit $VERIFY_RC)"
    why "$VERIFY"
    warn "check by hand: claude plugin marketplace list"
  elif printf '%s\n' "$VERIFY" | listed "$MARKETPLACE_NAME"; then
    ok "marketplace registered"
  else
    why "$VERIFY"
    fail "'claude plugin marketplace add' reported success, but '$MARKETPLACE_NAME' is not in the listing above"
  fi
elif [ -n "$UNKNOWN" ] || [ -n "$LISTING" ]; then
  # A rejected `add` may only mean it was already there. Two ways to be unsure:
  # the listing could not be read, or it was read and named nothing we know —
  # which is also how a listing format newer than listed() looks.
  warn "registering '$MARKETPLACE_NAME' from '$MARKETPLACE_GIT' failed (error above)"
  if [ -n "$UNKNOWN" ]; then
    warn "and whether '$MARKETPLACE_NAME' was already registered could not be determined"
  else
    warn "and '$MARKETPLACE_NAME' was not in this listing, which this script may be too old to read:"
    why "$LISTING"
  fi
  CAVEAT='could not be added; if it is already registered, this script could not tell.'
  NEXT="claude plugin marketplace list"
else
  fail "Failed to register marketplace '$MARKETPLACE_NAME' from '$MARKETPLACE_GIT'"
fi

# --- Done ---

if [ -n "$CAVEAT" ]; then
  printf '\n%b%bPunt Labs marketplace %s%b\n\n' "$YELLOW" "$BOLD" "$CAVEAT" "$NC"
  printf 'Do this next:\n'
  printf '  %s\n' "$NEXT"
else
  printf '\n%b%bPunt Labs marketplace is ready!%b\n\n' "$GREEN" "$BOLD" "$NC"
  printf 'Install all tools and plugins:\n'
  printf '  See https://github.com/punt-labs for the install-all.sh command.\n'
fi

# A human has read the banner by now; 2 is how a script learns the same thing.
[ -z "$CAVEAT" ] || exit 2
