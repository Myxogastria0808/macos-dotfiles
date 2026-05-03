#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ─── Xcode ────────────────────────────────────────────────────────────────────
echo "==> Xcode"
if ! [ -d "/Applications/Xcode.app" ]; then
  echo "Error: Xcode is not installed."
  echo "Please install it from the App Store:"
  echo "  https://apps.apple.com/jp/app/xcode/id497799835"
  exit 1
fi
echo "Xcode: OK"

# ─── Homebrew ─────────────────────────────────────────────────────────────────
echo "==> Homebrew"
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

# ─── Homebrew packages ────────────────────────────────────────────────────────
echo "==> Homebrew packages"
brew bundle --file="$DOTFILES_DIR/brew/Brewfile"

# ─── Nix (Determinate Systems: flakes + nix-command enabled by default) ───────
echo "==> Nix"
if ! command -v nix &>/dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
    | sh -s -- install
  # shellcheck source=/dev/null
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

# ─── home-manager ─────────────────────────────────────────────────────────────
echo "==> home-manager"
if ! command -v home-manager &>/dev/null; then
  nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
  nix-channel --update
  nix-shell '<home-manager>' -A install
fi

# ─── dotfiles (symlink) ───────────────────────────────────────────────────────
echo "==> dotfiles"
ln -sf "$DOTFILES_DIR/config/.zshrc" "$HOME/.zshrc"
mkdir -p "$HOME/.config"
ln -sf "$DOTFILES_DIR/config/starship.toml" "$HOME/.config/starship.toml"
mkdir -p "$HOME/.config/ghostty"
ln -sf "$DOTFILES_DIR/config/config.ghostty" "$HOME/.config/ghostty/config"

# ─── home-manager switch (nixvim) ─────────────────────────────────────────────
echo "==> home-manager switch"
home-manager switch --flake "$DOTFILES_DIR#macos"

echo ""
echo "Done! Restart your shell to apply all changes."
