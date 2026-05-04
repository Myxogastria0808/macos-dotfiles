#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=_lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"

if ! command -v defaults &>/dev/null; then
	err "'defaults' not found. This script requires macOS."
	exit 1
fi

echo "==> Keyboard"
defaults write NSGlobalDomain KeyRepeat -int 2
ok "Key repeat rate → 2 (30ms per key)"
defaults write NSGlobalDomain InitialKeyRepeat -int 20
ok "Initial repeat delay → 20 (300ms)"

