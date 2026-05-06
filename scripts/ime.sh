#!/usr/bin/env zsh
set -euo pipefail
source "${0:a:h}/_lib.sh"

if ! command -v defaults &>/dev/null; then
	err "'defaults' not found. This script requires macOS."
	exit 1
fi

echo "==> IME (macSKK)"

# ─── macSKK dictionaries ──────────────────────────────────────────────────────
_MACSKK_DICTS="$HOME/Library/Containers/net.mtgto.inputmethod.macSKK/Data/Documents/Dictionaries"

# Launch macSKK to initialize its container if the Dictionaries folder doesn't exist yet
if [ ! -d "$_MACSKK_DICTS" ]; then
	open "/Library/Input Methods/macSKK.app"
	i=0
	while [ ! -d "$_MACSKK_DICTS" ] && [ $i -lt 15 ]; do
		sleep 1
		i=$((i + 1))
	done
	unset i
fi
if [ ! -d "$_MACSKK_DICTS" ]; then
	action "macSKK container not initialized → launch macSKK manually, then re-run: bash $DOTFILES_DIR/scripts/ime.sh"
	return 0 2>/dev/null || exit 0
fi

# Stop macSKK before downloading to avoid concurrent writes to the Dictionaries folder
killall macSKK 2>/dev/null || true

_DICT_BASE="https://raw.githubusercontent.com/skk-dev/dict/master"

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

_fetch_dict SKK-JISYO.L             SKK-JISYO.L
_fetch_dict SKK-JISYO.propernoun    SKK-JISYO.propernoun
_fetch_dict SKK-JISYO.jinmei        SKK-JISYO.jinmei
_fetch_dict SKK-JISYO.fullname      SKK-JISYO.fullname
_fetch_dict SKK-JISYO.station       SKK-JISYO.station
_fetch_dict SKK-JISYO.geo           SKK-JISYO.geo
_fetch_dict SKK-JISYO.okinawa       SKK-JISYO.okinawa
_fetch_dict SKK-JISYO.law           SKK-JISYO.law
_fetch_dict SKK-JISYO.mazegaki      SKK-JISYO.mazegaki
_fetch_dict SKK-JISYO.emoji         SKK-JISYO.emoji
_fetch_dict SKK-JISYO.china_taiwan  SKK-JISYO.china_taiwan
_fetch_dict SKK-JISYO.JIS2          SKK-JISYO.JIS2
_fetch_dict SKK-JISYO.JIS2004       SKK-JISYO.JIS2004
_fetch_dict SKK-JISYO.JIS3_4        SKK-JISYO.JIS3_4
_fetch_dict SKK-JISYO.itaiji        SKK-JISYO.itaiji
_fetch_dict SKK-JISYO.itaiji.JIS3_4 SKK-JISYO.itaiji.JIS3_4
_fetch_dict SKK-JISYO.zipcode       zipcode/SKK-JISYO.zipcode

ok "17 dictionaries placed in Dictionaries/"

# ─── Manual steps required ────────────────────────────────────────────────────
# Input source registration via TIS API (TISEnableInputSource) does not persist
# to AppleEnabledInputSources on macOS Sequoia — must be done through System Settings.
# Dictionary plist registration is skipped because macSKK overwrites it on startup;
# enabling dictionaries from within the app is the only reliable approach.
action "macSKK: System Settings > Keyboard > Input Sources > + → add macSKK"
action "macSKK: macSKK Settings > Dictionaries → enable all 17 dictionaries"
