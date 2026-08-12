#!/bin/sh
# Register the Punt Labs marketplace for Claude Code plugins.
#
# For the install command, see the Quick Start in README.md. It is deliberately
# not repeated here: it carries a commit SHA, and a copy in this file would go
# stale the moment this file changed — which is precisely the bug that shipped
# once already (README pinned a SHA predating the fix it was meant to deliver).
# One pinned URL, in one place.
set -eu

# --- Colors (disabled when not a terminal) ---
if [ -t 1 ]; then
  BOLD='\033[1m' GREEN='\033[32m' YELLOW='\033[33m' NC='\033[0m'
else
  BOLD='' GREEN='' YELLOW='' NC=''
fi

info() { printf '%b▶%b %s\n' "$BOLD" "$NC" "$1"; }
ok()   { printf '  %b✓%b %s\n' "$GREEN" "$NC" "$1"; }
warn() { printf '  %b!%b %s\n' "$YELLOW" "$NC" "$1"; }
fail() { printf '  %b✗%b %s\n' "$YELLOW" "$NC" "$1"; exit 1; }

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

STALE=''
REGISTERED=''

# A marketplace name is its own line, decorated: "  ❯ punt-labs". Strip the
# decoration and compare the first field, so a fork registered under another
# name is not matched by the "Source: ... (punt-labs/claude-plugins)" line.
if LISTING=$(claude plugin marketplace list < /dev/null 2>&1); then
  if printf '%s\n' "$LISTING" |
     awk -v name="$MARKETPLACE_NAME" \
         '{ sub(/^[^[:alnum:]]+/, "") } $1 == name { found = 1 } END { exit !found }'
  then
    REGISTERED=yes
  fi
else
  warn "could not list marketplaces; assuming '$MARKETPLACE_NAME' is not registered"
  printf '%s\n' "$LISTING" >&2
fi

if [ -n "$REGISTERED" ]; then
  ok "marketplace already registered"
  if UPDATE_OUT=$(claude plugin marketplace update "$MARKETPLACE_NAME" < /dev/null 2>&1); then
    ok "marketplace updated"
  else
    STALE=yes
    warn "update failed; the local catalog may be stale"
    printf '%s\n' "$UPDATE_OUT" >&2
    warn "retry with: claude plugin marketplace update $MARKETPLACE_NAME"
  fi
else
  claude plugin marketplace add "$MARKETPLACE_REPO" < /dev/null || fail "Failed to register marketplace '$MARKETPLACE_REPO'"
  ok "marketplace registered"
fi

# --- Done ---

if [ -n "$STALE" ]; then
  printf '\n%b%bPunt Labs marketplace is registered, but the catalog may be stale.%b\n\n' "$YELLOW" "$BOLD" "$NC"
else
  printf '\n%b%bPunt Labs marketplace is ready!%b\n\n' "$GREEN" "$BOLD" "$NC"
fi
printf 'Install all tools and plugins:\n'
printf '  See https://github.com/punt-labs for the install-all.sh command.\n'
