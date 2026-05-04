#!/usr/bin/env zsh
set -euo pipefail
source "${0:a:h}/_lib.sh"

if ! command -v defaults &>/dev/null; then
	err "'defaults' not found. This script requires macOS."
	exit 1
fi

echo "==> Finder"
defaults write com.apple.finder AppleShowAllFiles -bool true
ok "Hidden files → shown"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
ok "File extensions → always visible"
killall Finder
ok "Finder restarted"

