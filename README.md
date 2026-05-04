# macos-dotfiles

My personal macOS dotfiles for Apple Silicon (M-series) Macs.

> **Supported OS**: macOS 26 only. Other versions are not supported.

## Overview

- **Package management**: Homebrew (primary), Nix (for Neovim only)
- **Shell**: zsh with [starship](https://starship.rs/) prompt, zsh-autosuggestions, zsh-syntax-highlighting
- **Editor**: Neovim via [nixvim](https://github.com/Myxogastria0808/nix-flakes-nixvim) + home-manager standalone
- **Terminal**: [Ghostty](https://ghostty.org/)
- **Languages**: Rust, Python (uv), R (rig), Julia (juliaup), Haskell (ghcup + stack), OCaml (opam), Lean4 (elan), Go, SWI-Prolog

## Repository Structure

```
macos-dotfiles/
├── install.sh           # Bootstrap script
├── ollama.sh            # Pull Ollama models (run separately)
├── flake.nix            # Nix flake (home-manager standalone)
├── brew/
│   └── Brewfile         # Homebrew packages
├── config/
│   ├── .zshrc           # → ~/.zshrc
│   ├── starship.toml    # → ~/.config/starship.toml
│   └── config.ghostty   # → ~/.config/ghostty/config
├── home/
│   └── home.nix         # home-manager configuration
└── scripts/             # macOS config scripts (called by install.sh, also runnable standalone)
    ├── _lib.sh          # Shared logging helpers
    ├── mouse.sh         # Mouse cursor size
    ├── menubar.sh       # Menu bar clock format
    ├── finder.sh        # Finder display settings
    ├── keyboard.sh      # Key repeat speed
    ├── ime.sh           # macSKK input method
    ├── dock.sh          # Dock layout and pinned apps
    ├── startup.sh       # Login items (Tailscale, Ollama)
    ├── tailscale.sh     # Tailscale service start + tailscale up (SSH, routes)
    ├── hostname.sh      # Computer name / LocalHostName / HostName
    ├── ssh.sh           # Remote Login (SSH)
    └── vnc.sh           # Remote Management (VNC)
```

## Prerequisites

- **macOS 26** (Apple Silicon) — this is the only supported OS version
- Install [Xcode](https://apps.apple.com/jp/app/xcode/id497799835) from the App Store before running the setup script.

## Setup

**Fork this repository** on GitHub, then clone your fork:

```sh
git clone https://github.com/<your-username>/macos-dotfiles.git ~/macos-dotfiles
cd ~/macos-dotfiles
./install.sh
```

> Forking lets you customize the Brewfile, Dock layout, and other settings for your own machine, and push changes back with `brew-update`.

The script will:

1. Verify Xcode is installed
2. Configure Git (`user.name`, `user.email`)
3. Install [Homebrew](https://brew.sh/) if not present
4. Install all packages via `brew bundle`
5. Install [Nix](https://determinate.systems/nix/) (Determinate Systems — flakes enabled by default)
6. Symlink dotfiles (`~/.zshrc`, `~/.config/starship.toml`, `~/.config/ghostty/config`)
7. Install language toolchains: Rust, Python, R, Julia, Haskell, OCaml, Lean4
8. Run `home-manager switch` to set up Neovim (nixvim)
9. Apply macOS system settings (mouse, menu bar, Finder, keyboard, IME, Dock, startup items)
10. Configure hostname, SSH, VNC (interactive)

### After running install.sh

The following require manual approval in **System Settings > Privacy & Security**:

| Permission       | Target        | Purpose            |
| ---------------- | ------------- | ------------------ |
| Full Disk Access | your terminal | SSH (Remote Login) |
| Automation       | your terminal | login items        |
| Screen Recording | ARDAgent      | VNC screen sharing |
| Accessibility    | ARDAgent      | VNC remote control |

ARDAgent path: `/System/Library/CoreServices/RemoteManagement/ARDAgent.app`

### Ollama models

Pull LLM models separately after Ollama is running:

```sh
sh ollama.sh
```

Models: qwen3.5 (0.8b / 2b / 4b / 9b / 27b / 35b / 122b), qwen3.6 (27b / 35b)

## Updating

### Homebrew packages

Dump installed packages and push to remote:

```sh
brew-update
```

### macOS config scripts

Each script in `scripts/` can be run independently:

```sh
./scripts/dock.sh
./scripts/keyboard.sh
# ...
```

### Neovim (nixvim)

```sh
hm
# expands to: home-manager switch --flake "$DOTFILES_DIR#macos"
```

### Update nix flake inputs

```sh
nix flake update
hm
```

