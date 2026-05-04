#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=_lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"

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

