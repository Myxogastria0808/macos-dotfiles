#!/usr/bin/env zsh
set -euo pipefail
source "${0:a:h}/_lib.sh"

if ! command -v defaults &>/dev/null; then
	err "'defaults' not found. This script requires macOS."
	exit 1
fi

echo "==> Menu Bar"
defaults write com.apple.menuextra.clock ShowSeconds -bool true
defaults write com.apple.menuextra.clock DateFormat -string "EEE d MMM H:mm:ss"
ok "Clock format → EEE d MMM H:mm:ss (seconds enabled)"

