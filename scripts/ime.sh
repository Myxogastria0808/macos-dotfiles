#!/usr/bin/env zsh
set -euo pipefail
source "${0:a:h}/_lib.sh"

if ! command -v defaults &>/dev/null; then
	err "'defaults' not found. This script requires macOS."
	exit 1
fi

echo "==> IME"
# Input Mode エントリが存在するかで「正しく登録済み」と判断する
if ! defaults read com.apple.HIToolbox AppleEnabledInputSources 2>/dev/null \
		| grep -A2 "net.mtgto.inputmethod.macSKK" | grep -q "Input Mode"; then
	defaults write com.apple.HIToolbox AppleEnabledInputSources -array \
		'<dict><key>InputSourceKind</key><string>Keyboard Layout</string><key>KeyboardLayout ID</key><integer>252</integer><key>KeyboardLayout Name</key><string>ABC</string></dict>' \
		'<dict><key>Bundle ID</key><string>net.mtgto.inputmethod.macSKK</string><key>Input Mode</key><string>net.mtgto.inputmethod.macSKK.hiragana</string><key>InputSourceKind</key><string>Input Mode</string></dict>' \
		'<dict><key>Bundle ID</key><string>net.mtgto.inputmethod.macSKK</string><key>InputSourceKind</key><string>Keyboard Input Method</string></dict>'
	defaults write com.apple.HIToolbox AppleSelectedInputSources -array \
		'<dict><key>Bundle ID</key><string>net.mtgto.inputmethod.macSKK</string><key>Input Mode</key><string>net.mtgto.inputmethod.macSKK.hiragana</string><key>InputSourceKind</key><string>Input Mode</string></dict>'
	killall -SIGKILL SystemUIServer
	ok "macSKK set as Japanese IME, SystemUIServer restarted"
else
	skip "macSKK (already registered)"
fi
