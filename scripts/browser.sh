#!/usr/bin/env zsh
set -euo pipefail
source "${0:a:h}/_lib.sh"

if ! command -v defaultbrowser &>/dev/null; then
	err "'defaultbrowser' not found. Install it with: brew install defaultbrowser"
	exit 1
fi

echo "==> Default browser"
defaultbrowser firefox
ok "Default browser → Google Chrome"

