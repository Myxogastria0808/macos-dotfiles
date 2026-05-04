#!/usr/bin/env zsh
set -euo pipefail
source "${0:a:h}/_lib.sh"

if ! command -v defaults &>/dev/null; then
	err "'defaults' not found. This script requires macOS."
	exit 1
fi

echo "==> IME"
# Keyboard Input Method + Input Mode の両エントリが有効、かつ選択済みかで判断する
_skk_enabled() {
	local sources
	sources=$(defaults read com.apple.HIToolbox AppleEnabledInputSources 2>/dev/null)
	echo "$sources" | grep -q "Keyboard Input Method" &&
		echo "$sources" | grep -A2 "net.mtgto.inputmethod.macSKK" | grep -q "Input Mode"
}
_skk_selected() {
	defaults read com.apple.HIToolbox AppleSelectedInputSources 2>/dev/null |
		grep -q "net.mtgto.inputmethod.macSKK"
}
if ! _skk_enabled || ! _skk_selected; then
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

# ─── macSKK dictionaries ──────────────────────────────────────────────────────
echo "==> macSKK dictionaries"
_MACSKK_DICTS="$HOME/Library/Containers/net.mtgto.inputmethod.macSKK/Data/Documents/Dictionaries"
_DICT_BASE="https://raw.githubusercontent.com/skk-dev/dict/master"

# ヘッダの coding: を見て EUC-JP → UTF-8 変換するか判断する
_fetch_dict() {
	local name="$1" repo_path="$2"
	local dest="$_MACSKK_DICTS/${name}.utf8"
	if [ -s "$dest" ]; then
		skip "${name}.utf8 (already exists)"
		return
	fi
	local tmp
	tmp=$(mktemp)
	curl -sSL "$_DICT_BASE/$repo_path" -o "$tmp"
	if head -1 "$tmp" | grep -q "coding: utf-8"; then
		mv "$tmp" "$dest"
	else
		iconv -c -f EUC-JP -t UTF-8 "$tmp" >"$dest"
		rm -f "$tmp"
	fi
	ok "$name downloaded"
}

_fetch_dict SKK-JISYO.L            SKK-JISYO.L
_fetch_dict SKK-JISYO.propernoun   SKK-JISYO.propernoun
_fetch_dict SKK-JISYO.jinmei       SKK-JISYO.jinmei
_fetch_dict SKK-JISYO.fullname     SKK-JISYO.fullname
_fetch_dict SKK-JISYO.station      SKK-JISYO.station
_fetch_dict SKK-JISYO.geo          SKK-JISYO.geo
_fetch_dict SKK-JISYO.okinawa      SKK-JISYO.okinawa
_fetch_dict SKK-JISYO.law          SKK-JISYO.law
_fetch_dict SKK-JISYO.mazegaki     SKK-JISYO.mazegaki
_fetch_dict SKK-JISYO.emoji        SKK-JISYO.emoji
_fetch_dict SKK-JISYO.china_taiwan SKK-JISYO.china_taiwan
_fetch_dict SKK-JISYO.JIS2         SKK-JISYO.JIS2
_fetch_dict SKK-JISYO.JIS2004      SKK-JISYO.JIS2004
_fetch_dict SKK-JISYO.JIS3_4       SKK-JISYO.JIS3_4
_fetch_dict SKK-JISYO.itaiji       SKK-JISYO.itaiji
_fetch_dict SKK-JISYO.itaiji.JIS3_4 SKK-JISYO.itaiji.JIS3_4
_fetch_dict SKK-JISYO.zipcode      zipcode/SKK-JISYO.zipcode

