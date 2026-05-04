#!/usr/bin/env zsh
set -euo pipefail
source "${0:a:h}/_lib.sh"

if ! command -v tailscale &>/dev/null; then
	err "'tailscale' not found. Install via Homebrew: brew install tailscale"
	exit 1
fi

echo "==> Tailscale"

if sudo brew services list 2>/dev/null | grep -qE "^tailscale[[:space:]]+started"; then
	skip "Tailscale service (already running)"
else
	if sudo brew services start tailscale; then
		ok "Tailscale service started"
	else
		err "Failed to start Tailscale service"
		exit 1
	fi
fi

if tailscale status &>/dev/null; then
	skip "Tailscale (already connected)"
else
	if sudo tailscale up --ssh --accept-routes; then
		ok "Tailscale connected (SSH enabled, routes accepted)"
	else
		err "Failed to connect Tailscale"
		exit 1
	fi
fi

