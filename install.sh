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
	curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix |
		sh -s -- install macos --encrypt false --no-confirm
	# shellcheck source=/dev/null
	. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

# ─── dotfiles (symlink) ───────────────────────────────────────────────────────
echo "==> dotfiles"
ln -sf "$DOTFILES_DIR/config/.zshrc" "$HOME/.zshrc"
mkdir -p "$HOME/.config"
ln -sf "$DOTFILES_DIR/config/starship.toml" "$HOME/.config/starship.toml"
mkdir -p "$HOME/.config/ghostty"
ln -sf "$DOTFILES_DIR/config/config.ghostty" "$HOME/.config/ghostty/config"

# ─── Rust ─────────────────────────────────────────────────────────────────────
echo "==> Rust"
rustup default stable

# ─── Python ───────────────────────────────────────────────────────────────────
echo "==> Python"
uv python install

# ─── R ────────────────────────────────────────────────────────────────────────
echo "==> R"
sudo rig add release

# ─── Julia ────────────────────────────────────────────────────────────────────
echo "==> Julia"
juliaup add release
juliaup default release

# ─── Haskell ──────────────────────────────────────────────────────────────────
echo "==> Haskell"
ghcup install ghc recommended
ghcup install hls latest
ghcup set ghc recommended
stack setup

# ─── OCaml ────────────────────────────────────────────────────────────────────
echo "==> OCaml"
opam init -y

# ─── Lean4 ────────────────────────────────────────────────────────────────────
echo "==> Lean4"
elan default stable

# ─── home-manager switch (nixvim) ─────────────────────────────────────────────
echo "==> home-manager switch"
nix run home-manager/master -- switch --flake "$DOTFILES_DIR#macos"

# ─── Mouse ────────────────────────────────────────────────────────────────────
echo "==> Mouse"
if ! defaults write com.apple.universalaccess mouseDriverCursorSize -float 2.5 2>/dev/null; then
	echo "Error: Failed to set cursor size."
	echo "  => Grant Accessibility permission to your terminal in System Settings > Privacy & Security > Accessibility, then re-run."
fi

# ─── Menu Bar ─────────────────────────────────────────────────────────────────
echo "==> Menu Bar"
defaults write com.apple.menuextra.clock ShowSeconds -bool true
defaults write com.apple.menuextra.clock DateFormat -string "EEE d MMM H:mm:ss"

# ─── Finder ───────────────────────────────────────────────────────────────────
echo "==> Finder"
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
killall Finder

# ─── Keyboard ─────────────────────────────────────────────────────────────────
echo "==> Keyboard"
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 10

# ─── IME (macSKK) ─────────────────────────────────────────────────────────────
echo "==> IME"
if ! defaults read com.apple.HIToolbox AppleEnabledInputSources 2>/dev/null | grep -q "net.mtgto.inputmethod.macSKK"; then
	defaults write com.apple.HIToolbox AppleEnabledInputSources -array-add \
		'<dict><key>Bundle ID</key><string>net.mtgto.inputmethod.macSKK</string><key>InputSourceKind</key><string>Keyboard Input Method</string></dict>'
fi

# ─── Dock ─────────────────────────────────────────────────────────────────────
echo "==> Dock"
defaults write com.apple.dock orientation -string "bottom"
defaults write com.apple.dock tilesize -int 48
defaults write com.apple.dock autohide -bool false
defaults write com.apple.dock show-recents -bool false

dockutil --remove all --no-restart
dockutil --add /System/Library/CoreServices/Finder.app --no-restart
dockutil --add /System/Applications/System\ Settings.app --no-restart
dockutil --add /System/Applications/Apps.app --no-restart
dockutil --add /Applications/Google\ Chrome.app --no-restart
dockutil --add /Applications/Ghostty.app --no-restart
dockutil --add /Applications/Claude.app --no-restart
dockutil --add /Applications/Codex.app --no-restart
dockutil --add /Applications/Discord.app --no-restart
dockutil --add /Applications/Slack.app --no-restart
dockutil --add /Applications/Ollama.app --no-restart
dockutil --add /Applications/Notion.app --no-restart
dockutil --add '/Applications/Notion Calendar.app' --no-restart
dockutil --add /Applications/Bitwarden.app --no-restart

# ─── SSH (Remote Login) ───────────────────────────────────────────────────────
echo "==> SSH"
if ! sudo systemsetup -setremotelogin on 2>/dev/null; then
	echo "Error: Failed to enable Remote Login."
	echo "  => Grant Full Disk Access to your terminal in System Settings > Privacy & Security > Full Disk Access, then re-run."
fi

# ─── VNC (Screen Sharing) ─────────────────────────────────────────────────────
echo "==> VNC"
read -rs -p "VNC password (empty to skip): " VNC_PASSWORD
echo ""
if [ -n "$VNC_PASSWORD" ]; then
	sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.screensharing.plist
	sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart \
		-configure -clientopts -setvnclegacy -vnclegacy yes \
		-clientopts -setvncpw -vncpw "$VNC_PASSWORD"
else
	echo "Skipped."
fi

echo ""
echo "Done! Restart your shell to apply all changes."

