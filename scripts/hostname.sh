#!/usr/bin/env zsh
set -euo pipefail
source "${0:a:h}/_lib.sh"

if ! command -v scutil &>/dev/null; then
	err "'scutil' not found. This script requires macOS."
	exit 1
fi

echo "==> Hostname"
echo "  Current: ComputerName  = $(scutil --get ComputerName 2>/dev/null || echo '(not set)')"
echo "  Current: LocalHostName = $(scutil --get LocalHostName 2>/dev/null || echo '(not set)')"
echo "  Current: HostName      = $(scutil --get HostName 2>/dev/null || echo '(not set)')"
read -r "COMPUTER_NAME?Computer name (shown in Finder/AirDrop; spaces and Unicode allowed; empty to skip): "
while true; do
	read -r "LOCAL_NAME?Local/Host name (used for Bonjour and shell prompt; alphanumeric and hyphens only, must not start or end with a hyphen; empty to skip): "
	if [ -z "$LOCAL_NAME" ]; then
		break
	elif [[ "$LOCAL_NAME" =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$ ]]; then
		break
	else
		err "Invalid format. Use only letters, digits, and hyphens; do not start or end with a hyphen."
	fi
done
if [ -n "$COMPUTER_NAME" ]; then
	sudo scutil --set ComputerName "$COMPUTER_NAME"
	ok "ComputerName → $COMPUTER_NAME"
else
	skip "ComputerName"
fi
if [ -n "$LOCAL_NAME" ]; then
	sudo scutil --set LocalHostName "$LOCAL_NAME"
	sudo scutil --set HostName "$LOCAL_NAME"
	ok "LocalHostName / HostName → $LOCAL_NAME"
else
	skip "LocalHostName / HostName"
fi
