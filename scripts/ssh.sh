#!/usr/bin/env zsh
set -euo pipefail
source "${0:a:h}/_lib.sh"

if [ ! -f "/usr/sbin/systemsetup" ]; then
	err "'systemsetup' not found. This script requires macOS."
	exit 1
fi

echo "==> SSH"
if sudo systemsetup -setremotelogin on 2>/dev/null; then
	ok "Remote Login enabled"
else
	err "Failed to enable Remote Login"
	action "Required: System Settings > Privacy & Security > Full Disk Access → add your terminal, then re-run."
fi

