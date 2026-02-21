#!/bin/sh
# Install the Punt Labs plugin marketplace for Claude Code.
# Usage: curl -fsSL https://raw.githubusercontent.com/punt-labs/claude-plugins/main/install.sh | sh
set -eu

# --- Colors (safe for pipes — disabled when not a terminal) ---
if [ -t 1 ]; then
  BOLD='\033[1m'
  GREEN='\033[32m'
  YELLOW='\033[33m'
  CYAN='\033[36m'
  RESET='\033[0m'
else
  BOLD='' GREEN='' YELLOW='' CYAN='' RESET=''
fi

info()  { printf '%b%s%b\n' "$CYAN"   "$1" "$RESET"; }
ok()    { printf '%b%s%b\n' "$GREEN"  "$1" "$RESET"; }
warn()  { printf '%b%s%b\n' "$YELLOW" "$1" "$RESET"; }

MARKETPLACE_REPO="punt-labs/claude-plugins"
MARKETPLACE_NAME="punt-labs"

# --- Pre-flight checks ---

# 1. Claude Code CLI must exist
if ! command -v claude >/dev/null 2>&1; then
  warn "Error: 'claude' CLI not found on PATH."
  warn "Install Claude Code first: https://docs.anthropic.com/en/docs/claude-code"
  exit 1
fi

# 2. Verify the marketplace catalog is reachable and show its contents
CATALOG_URL="https://raw.githubusercontent.com/${MARKETPLACE_REPO}/main/.claude-plugin/marketplace.json"
info "Fetching marketplace catalog from ${MARKETPLACE_REPO}..."

if command -v curl >/dev/null 2>&1; then
  CATALOG="$(curl -fsSL "$CATALOG_URL")" || {
    warn "Error: could not fetch marketplace catalog."
    warn "URL: $CATALOG_URL"
    exit 1
  }
elif command -v wget >/dev/null 2>&1; then
  CATALOG="$(wget -qO- "$CATALOG_URL")" || {
    warn "Error: could not fetch marketplace catalog."
    warn "URL: $CATALOG_URL"
    exit 1
  }
else
  warn "Error: neither curl nor wget found."
  exit 1
fi

# 3. Show what the marketplace contains
printf '\n%bPunt Labs Marketplace Catalog%b\n' "$BOLD" "$RESET"
printf '%b──────────────────────────────%b\n' "$CYAN" "$RESET"

# Parse plugin names and repos from the catalog JSON (POSIX-safe, no jq required)
printf '%s\n' "$CATALOG" | while IFS= read -r line; do
  case "$line" in
    *'"name"'*)
      name="$(printf '%s' "$line" | sed 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')"
      # Skip the marketplace-level name
      ;;
    *'"repo"'*)
      repo="$(printf '%s' "$line" | sed 's/.*"repo"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')"
      printf '  %b•%b %s  →  github.com/%s\n' "$GREEN" "$RESET" "$name" "$repo"
      ;;
  esac
done

# 4. Compute and display the catalog checksum for verification
checksum="$(printf '%s' "$CATALOG" | shasum -a 256 | cut -d' ' -f1)"
printf '\n  catalog sha256: %b%s%b\n' "$CYAN" "$checksum" "$RESET"
printf '  verify at: https://github.com/%s\n\n' "$MARKETPLACE_REPO"

# --- Register the marketplace ---

# Check if already registered
if claude plugin marketplace list 2>/dev/null | grep -q "$MARKETPLACE_NAME"; then
  ok "Marketplace '$MARKETPLACE_NAME' is already registered. Updating..."
  claude plugin marketplace update "$MARKETPLACE_NAME"
else
  info "Registering marketplace: $MARKETPLACE_REPO"
  claude plugin marketplace add "$MARKETPLACE_REPO"
fi

ok "Done! Marketplace '$MARKETPLACE_NAME' is ready."
printf '\nInstall a plugin:\n'
printf '  claude plugin install punt@%s\n' "$MARKETPLACE_NAME"
printf '  claude plugin install dungeon@%s\n' "$MARKETPLACE_NAME"
printf '  claude plugin install biff@%s\n\n' "$MARKETPLACE_NAME"
