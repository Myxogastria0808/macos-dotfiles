#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=_lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"

if ! command -v defaults &>/dev/null; then
	err "'defaults' not found. This script requires macOS."
	exit 1
fi

echo "==> IME"
if ! defaults read com.apple.HIToolbox AppleEnabledInputSources 2>/dev/null | grep -q "net.mtgto.inputmethod.macSKK"; then
	defaults write com.apple.HIToolbox AppleEnabledInputSources -array-add \
		'<dict><key>Bundle ID</key><string>net.mtgto.inputmethod.macSKK</string><key>InputSourceKind</key><string>Keyboard Input Method</string></dict>'
	killall -SIGKILL SystemUIServer
	ok "macSKK registered, SystemUIServer restarted"
else
	skip "macSKK (already registered)"
fi
