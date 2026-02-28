#!/bin/sh
# Register the Punt Labs marketplace for Claude Code plugins.
# Usage: curl -fsSL https://raw.githubusercontent.com/punt-labs/claude-plugins/main/install.sh | sh
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

if claude plugin marketplace list 2>/dev/null | grep -q "$MARKETPLACE_NAME"; then
  ok "marketplace already registered"
  claude plugin marketplace update "$MARKETPLACE_NAME" 2>/dev/null || true
else
  claude plugin marketplace add "$MARKETPLACE_REPO" || fail "Failed to register marketplace"
  ok "marketplace registered"
fi

# --- Done ---

printf '\n%b%bPunt Labs marketplace is ready!%b\n\n' "$GREEN" "$BOLD" "$NC"
printf 'Install a plugin:\n'
printf '  curl -fsSL https://raw.githubusercontent.com/punt-labs/tts/main/install.sh | sh\n'
printf '  curl -fsSL https://raw.githubusercontent.com/punt-labs/biff/main/install.sh | sh\n'
printf '  curl -fsSL https://raw.githubusercontent.com/punt-labs/quarry/main/install.sh | sh\n'
printf '  curl -fsSL https://raw.githubusercontent.com/punt-labs/prfaq/main/install.sh | sh\n'
printf '  curl -fsSL https://raw.githubusercontent.com/punt-labs/z-spec/main/install.sh | sh\n'
printf '  curl -fsSL https://raw.githubusercontent.com/punt-labs/dungeon/main/install.sh | sh\n'
