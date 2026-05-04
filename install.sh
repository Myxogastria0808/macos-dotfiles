#!/usr/bin/env zsh
set -euo pipefail

DOTFILES_DIR="${0:a:h}"
source "$DOTFILES_DIR/scripts/_lib.sh"

# ─── Xcode ────────────────────────────────────────────────────────────────────
echo "==> Xcode"
if ! [ -d "/Applications/Xcode.app" ]; then
	echo "Error: Xcode is not installed."
	echo "Please install it from the App Store:"
	echo "  https://apps.apple.com/jp/app/xcode/id497799835"
	exit 1
fi
echo "Xcode: OK"

# ─── Git ──────────────────────────────────────────────────────────────────────
echo "==> Git"
echo "  Current: user.name  = $(git config --global user.name 2>/dev/null || echo '(not set)')"
echo "  Current: user.email = $(git config --global user.email 2>/dev/null || echo '(not set)')"
read -r "GIT_NAME?Git user name (empty to skip): "
read -r "GIT_EMAIL?Git user email (empty to skip): "
if [ -n "$GIT_NAME" ]; then
	git config --global user.name "$GIT_NAME"
else
	echo "user.name: Skipped."
fi
if [ -n "$GIT_EMAIL" ]; then
	git config --global user.email "$GIT_EMAIL"
else
	echo "user.email: Skipped."
fi

# ─── Homebrew ─────────────────────────────────────────────────────────────────
echo "==> Homebrew"
if ! command -v brew &>/dev/null; then
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	ok "Homebrew installed"
else
	skip "Homebrew (already installed)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

# ─── Homebrew packages ────────────────────────────────────────────────────────
echo "==> Homebrew packages"
brew bundle --file="$DOTFILES_DIR/brew/Brewfile"
ok "Brewfile applied"

# ─── Nix (Determinate Systems: flakes + nix-command enabled by default) ───────
echo "==> Nix"
if ! command -v nix &>/dev/null; then
	curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix |
		sh -s -- install macos --encrypt false --no-confirm
	# shellcheck source=/dev/null
	. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
	ok "Nix installed → $(nix --version)"
else
	skip "Nix (already installed: $(nix --version))"
fi

# ─── dotfiles (symlink) ───────────────────────────────────────────────────────
echo "==> dotfiles"
ln -sf "$DOTFILES_DIR/config/.zshrc" "$HOME/.zshrc"
mkdir -p "$HOME/.config"
ln -sf "$DOTFILES_DIR/config/starship.toml" "$HOME/.config/starship.toml"
mkdir -p "$HOME/.config/ghostty"
ln -sf "$DOTFILES_DIR/config/config.ghostty" "$HOME/.config/ghostty/config"
ok ".zshrc, starship.toml, ghostty/config → symlinked"

# ─── Rust ─────────────────────────────────────────────────────────────────────
echo "==> Rust"
if ! rustup toolchain list 2>/dev/null | grep -q "^stable"; then
	rustup default stable
	ok "stable toolchain installed"
else
	skip "Rust stable (already installed)"
fi

# ─── Python ───────────────────────────────────────────────────────────────────
echo "==> Python"
if ! uv python list 2>/dev/null | grep -q "cpython"; then
	uv python install
	ok "CPython installed via uv"
else
	skip "Python (already installed)"
fi

# ─── R ────────────────────────────────────────────────────────────────────────
echo "==> R"
if ! command -v R &>/dev/null; then
	sudo rig add release
	ok "R release installed via rig"
else
	skip "R (already installed)"
fi

# ─── Julia ────────────────────────────────────────────────────────────────────
echo "==> Julia"
if ! juliaup status 2>/dev/null | grep -q "release"; then
	juliaup add release
	juliaup default release
	ok "Julia release channel installed and set as default"
else
	skip "Julia (already installed)"
fi

# ─── Haskell ──────────────────────────────────────────────────────────────────
echo "==> Haskell"
if [ ! -x "$HOME/.ghcup/bin/ghc" ]; then
	ghcup install ghc recommended
	ghcup install hls latest
	ghcup set ghc recommended
	stack setup
	ok "GHC (recommended) + HLS (latest) + Stack installed"
else
	skip "Haskell (already installed)"
fi

# ─── OCaml ────────────────────────────────────────────────────────────────────
echo "==> OCaml"
if [ ! -d "$HOME/.opam" ]; then
	opam init -y
	ok "opam initialized"
else
	skip "OCaml (already initialized)"
fi

# ─── Lean4 ────────────────────────────────────────────────────────────────────
echo "==> Lean4"
if [ ! -x "$HOME/.elan/bin/lean" ]; then
	elan default stable
	ok "Lean4 stable toolchain installed"
else
	skip "Lean4 (already installed)"
fi

# ─── home-manager switch (nixvim) ─────────────────────────────────────────────
echo "==> home-manager switch"
nix run home-manager/master -- switch --flake "$DOTFILES_DIR#macos"
ok "home-manager switch applied"

# ─── macOS config ─────────────────────────────────────────────────────────────
"$DOTFILES_DIR/scripts/mouse.sh"
"$DOTFILES_DIR/scripts/menubar.sh"
"$DOTFILES_DIR/scripts/finder.sh"
"$DOTFILES_DIR/scripts/keyboard.sh"
"$DOTFILES_DIR/scripts/ime.sh"
"$DOTFILES_DIR/scripts/dock.sh"
"$DOTFILES_DIR/scripts/startup.sh"
"$DOTFILES_DIR/scripts/hostname.sh"
"$DOTFILES_DIR/scripts/ssh.sh"
"$DOTFILES_DIR/scripts/vnc.sh"

echo ""
printf "\033[1m%s\033[0m\n" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
printf "\033[1m  Installation complete!\033[0m\n"
printf "  Restart your machine to apply all changes.\n"
echo ""
printf "\033[1;35m  Manual actions required:\033[0m\n"
action "System Settings > Privacy & Security > Full Disk Access   → add your terminal  (for SSH)"
action "System Settings > Privacy & Security > Automation         → add your terminal  (for login items)"
action "System Settings > Privacy & Security > Screen Recording   → add ARDAgent       (for VNC screen)"
action "System Settings > Privacy & Security > Accessibility      → add ARDAgent       (for VNC control)"
printf "\033[1m%s\033[0m\n" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

