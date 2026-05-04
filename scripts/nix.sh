#!/usr/bin/env zsh
set -euo pipefail

DOTFILES_DIR="${0:a:h}/.."
source "$DOTFILES_DIR/scripts/_lib.sh"

echo "==> Nix"
if ! command -v nix &>/dev/null; then
	curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix |
		sh -s -- install macos --encrypt true --no-confirm
	. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
	ok "Nix installed → $(nix --version)"
else
	skip "Nix (already installed: $(nix --version))"
fi
