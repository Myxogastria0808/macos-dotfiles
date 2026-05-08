#!/usr/bin/env zsh
set -euo pipefail
source "${0:a:h}/_lib.sh"

if ! command -v go &>/dev/null; then
	err "'go' not found. Install via Homebrew: brew install go"
	exit 1
fi

echo "==> Tailscale"

_GOBIN="$(go env GOPATH)/bin"

if [ -x "$_GOBIN/tailscale" ] && [ -x "$_GOBIN/tailscaled" ]; then
	skip "Tailscale (already installed)"
else
	go install tailscale.com/cmd/tailscale@latest tailscale.com/cmd/tailscaled@latest
	ok "Tailscale installed via go"
fi

if sudo launchctl list 2>/dev/null | grep -q "com.tailscale.tailscaled"; then
	skip "Tailscale daemon (already registered)"
else
	sudo "$_GOBIN/tailscaled" install-system-daemon
	_i=0
	while [ $_i -lt 15 ] && ! "$_GOBIN/tailscale" status &>/dev/null; do
		sleep 1
		_i=$((_i + 1))
	done
	unset _i
	ok "Tailscale system daemon installed"
fi

if "$_GOBIN/tailscale" status &>/dev/null; then
	skip "Tailscale (already connected)"
else
	action "Tailscale needs browser authentication — a URL will appear below. Open it to log in."
	if sudo "$_GOBIN/tailscale" up --ssh --accept-routes; then
		ok "Tailscale connected (SSH enabled, routes accepted)"
	else
		err "Failed to connect Tailscale"
		exit 1
	fi
fi

# ─── Manual steps required ────────────────────────────────────────────────────
action "Tailscale: System Settings > Privacy & Security > Full Disk Access → add Tailscale"
