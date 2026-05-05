#!/usr/bin/env zsh
set -euo pipefail
source "${0:a:h}/_lib.sh"

if ! command -v defaults &>/dev/null; then
	err "'defaults' not found. This script requires macOS."
	exit 1
fi

echo "==> IME"
if defaults read com.apple.HIToolbox AppleEnabledInputSources 2>/dev/null | grep -q "net.mtgto.inputmethod.macSKK"; then
	skip "macSKK (already registered)"
else
	swift "${0:a:h}/set-input-source.swift"
	killall -SIGKILL SystemUIServer
	ok "macSKK enabled via TIS API"
fi

# ─── macSKK dictionaries ──────────────────────────────────────────────────────
echo "==> macSKK dictionaries"
_MACSKK_DICTS="$HOME/Library/Containers/net.mtgto.inputmethod.macSKK/Data/Documents/Dictionaries"
_PLIST="$HOME/Library/Containers/net.mtgto.inputmethod.macSKK/Data/Library/Preferences/net.mtgto.inputmethod.macSKK.plist"

# Dictionaries フォルダがなければ macSKK を起動して作らせる
if [ ! -d "$_MACSKK_DICTS" ]; then
	open "/Library/Input Methods/macSKK.app"
	local i=0
	while [ ! -d "$_MACSKK_DICTS" ] && [ $i -lt 15 ]; do
		sleep 1
		i=$((i + 1))
	done
fi
if [ ! -d "$_MACSKK_DICTS" ]; then
	action "macSKK container not initialized → launch macSKK manually, then re-run: bash $DOTFILES_DIR/scripts/ime.sh"
	return 0 2>/dev/null || exit 0
fi

# ダウンロード中に macSKK がファイルを検出して enabled=false で追加するのを防ぐため
# ダウンロード前に停止する
killall macSKK 2>/dev/null || true

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

# ─── plist に登録・有効化 ─────────────────────────────────────────────────────
# macSKK は停止中なので自動検出は走らない。直接 plist に書く。
echo "==> macSKK dictionary registration"
if [ ! -f "$_PLIST" ]; then
	action "macSKK plist not found → open macSKK from Launchpad once, then re-run: bash $DOTFILES_DIR/scripts/ime.sh"
	return 0 2>/dev/null || exit 0
fi

_enabled=$(/usr/libexec/PlistBuddy -c "Print :dictionaries" "$_PLIST" 2>/dev/null | grep -c "enabled = true" || echo 0)
if [ "$_enabled" -eq 17 ]; then
	skip "all 17 dictionaries already registered and enabled"
else
	/usr/libexec/PlistBuddy -c "Delete :dictionaries" "$_PLIST" 2>/dev/null || true
	/usr/libexec/PlistBuddy -c "Add :dictionaries array" "$_PLIST"
	_i=0
	for _name in \
		SKK-JISYO.L SKK-JISYO.propernoun SKK-JISYO.jinmei SKK-JISYO.fullname \
		SKK-JISYO.station SKK-JISYO.geo SKK-JISYO.okinawa SKK-JISYO.law \
		SKK-JISYO.mazegaki SKK-JISYO.emoji SKK-JISYO.china_taiwan \
		SKK-JISYO.JIS2 SKK-JISYO.JIS2004 SKK-JISYO.JIS3_4 \
		SKK-JISYO.itaiji SKK-JISYO.itaiji.JIS3_4 SKK-JISYO.zipcode; do
		/usr/libexec/PlistBuddy \
			-c "Add :dictionaries:${_i} dict" \
			-c "Add :dictionaries:${_i}:enabled bool true" \
			-c "Add :dictionaries:${_i}:encoding integer 4" \
			-c "Add :dictionaries:${_i}:filename string ${_name}.utf8" \
			-c "Add :dictionaries:${_i}:saveToUserDict bool true" \
			-c "Add :dictionaries:${_i}:type string traditional" \
			"$_PLIST"
		_i=$((_i + 1))
	done
	ok "$_i dictionaries registered and enabled"
fi

open "/Library/Input Methods/macSKK.app"
