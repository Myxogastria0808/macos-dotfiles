#!/usr/bin/env zsh
set -euo pipefail
source "${0:a:h}/_lib.sh"

KICKSTART="/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart"

if [ ! -f "$KICKSTART" ]; then
	err "ARDAgent kickstart not found. This script requires macOS."
	exit 1
fi

echo "==> VNC"
read -rs "VNC_PASSWORD?VNC password (empty to skip): "
echo ""
if [ -n "$VNC_PASSWORD" ]; then
	sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.screensharing.plist 2>/dev/null || true
	sudo "$KICKSTART" \
		-activate -configure -access -on \
		-clientopts -setvnclegacy -vnclegacy yes \
		-clientopts -setvncpw -vncpw "$VNC_PASSWORD"
	ok "Remote Management activated"
	ok "VNC password set"
	echo ""
	action "Required: System Settings > Privacy & Security > Screen Recording → add ARDAgent"
	action "Required: System Settings > Privacy & Security > Accessibility  → add ARDAgent"
	echo "         (ARDAgent: /System/Library/CoreServices/RemoteManagement/ARDAgent.app)"
else
	skip "VNC (no password provided)"
fi
