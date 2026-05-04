#!/usr/bin/env zsh
set -euo pipefail
source "${0:a:h}/_lib.sh"

if ! command -v osascript &>/dev/null; then
	err "'osascript' not found. This script requires macOS."
	exit 1
fi

echo "==> Startup"
_login_items=$(osascript -e 'tell application "System Events" to get the name of every login item' 2>/dev/null || true)
for _entry in "Tailscale:/Applications/Tailscale.app" "Ollama:/Applications/Ollama.app"; do
	_name="${_entry%%:*}"
	_path="${_entry#*:}"
	if ! echo "$_login_items" | grep -q "$_name"; then
		if osascript -e "tell application \"System Events\" to make login item at end with properties {path:\"$_path\", hidden:true, name:\"$_name\"}" 2>/dev/null; then
			ok "$_name → added to login items"
		else
			err "Failed to add $_name to login items"
			action "Required: System Settings > Privacy & Security > Automation → add your terminal, then re-run."
		fi
	else
		skip "$_name (already in login items)"
	fi
done
unset _login_items _entry _name _path

