#!/usr/bin/env zsh
set -euo pipefail
source "${0:a:h}/_lib.sh"

if ! command -v defaults &>/dev/null; then
	err "'defaults' not found. This script requires macOS."
	exit 1
fi

echo "==> Mouse"
if defaults write com.apple.universalaccess mouseDriverCursorSize -float 2.5 2>/dev/null; then
	ok "Cursor size → 2.5x"
else
	err "Failed to set cursor size"
fi

