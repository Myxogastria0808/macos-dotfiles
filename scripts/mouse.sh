#!/usr/bin/env zsh
set -euo pipefail
source "${0:a:h}/_lib.sh"

if ! command -v defaults &>/dev/null; then
	err "'defaults' not found. This script requires macOS."
	exit 1
fi

if ! defaults write com.apple.universalaccess _fda_check_ -bool true 2>/dev/null; then
	err "Full Disk Access is required. Grant it to your terminal app in:"
	err "  System Settings > Privacy & Security > Full Disk Access"
	open "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles"
	exit 1
fi
defaults delete com.apple.universalaccess _fda_check_ 2>/dev/null

echo "==> Mouse"
defaults write com.apple.universalaccess mouseDriverCursorSize -float 2.5
ok "Cursor size → 2.5x"

