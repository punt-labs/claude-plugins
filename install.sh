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
#   1  the marketplace could not be registered
#   2  neither could be established: `add` reported success but the listing
#      that would confirm it could not be read, or an already-registered
#      marketplace could not be updated and its catalog may be stale
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

MARKETPLACE_REPO="punt-labs/claude-plugins"
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

# --- Step 2: Register marketplace ---

info "Registering Punt Labs marketplace..."

# Empty means "ready". Otherwise it holds the rest of the closing banner's
# first sentence, and is the reason this script exits 2.
CAVEAT=''
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
    warn "update failed (exit $UPDATE_RC); the local catalog may be stale"
    why "$UPDATE_OUT"
    warn "retry with: claude plugin marketplace update $MARKETPLACE_NAME"
  fi
elif claude plugin marketplace add "$MARKETPLACE_REPO" < /dev/null; then
  # `add` exiting 0 is a claim, not proof. Confirm the name is in the listing.
  VERIFY=$(claude plugin marketplace list < /dev/null 2>&1) && VERIFY_RC=0 || VERIFY_RC=$?
  if [ "$VERIFY_RC" -ne 0 ]; then
    CAVEAT='registration was reported, but could not be confirmed.'
    warn "'add' reported success, but the confirming re-list failed (exit $VERIFY_RC)"
    why "$VERIFY"
    warn "check by hand: claude plugin marketplace list"
  elif printf '%s\n' "$VERIFY" | listed "$MARKETPLACE_NAME"; then
    ok "marketplace registered"
  else
    why "$VERIFY"
    fail "'claude plugin marketplace add' reported success, but '$MARKETPLACE_NAME' is not in the listing above"
  fi
elif [ -n "$UNKNOWN" ]; then
  # The listing failed, so a rejected add may only mean it was already there.
  # Report what we know instead of guessing from the error text above.
  warn "could not determine whether '$MARKETPLACE_NAME' was already registered"
  fail "and registering '$MARKETPLACE_REPO' failed too (error above). Check by hand: claude plugin marketplace list"
else
  fail "Failed to register marketplace '$MARKETPLACE_REPO'"
fi

# --- Done ---

if [ -n "$CAVEAT" ]; then
  printf '\n%b%bPunt Labs marketplace %s%b\n\n' "$YELLOW" "$BOLD" "$CAVEAT" "$NC"
else
  printf '\n%b%bPunt Labs marketplace is ready!%b\n\n' "$GREEN" "$BOLD" "$NC"
fi
printf 'Install all tools and plugins:\n'
printf '  See https://github.com/punt-labs for the install-all.sh command.\n'

# A human has read the banner by now; 2 is how a script learns the same thing.
[ -z "$CAVEAT" ] || exit 2
