# macos-dotfiles

My personal macOS dotfiles for Apple Silicon (M-series) Macs.

## Overview

- **Package management**: Homebrew (primary), Nix (for Neovim only)
- **Neovim**: Managed via [nixvim](https://github.com/Myxogastria0808/nix-flakes-nixvim) + home-manager standalone
- **Shell**: zsh with [starship](https://starship.rs/) prompt

## Repository Structure

```
macos-dotfiles/
├── install.sh           # Bootstrap script
├── flake.nix            # Nix flake (home-manager standalone)
├── brew/
│   └── Brewfile         # Homebrew packages
├── config/
│   ├── .zshrc           # → ~/.zshrc
│   ├── starship.toml    # → ~/.config/starship.toml
│   └── config.ghostty   # → ~/.config/ghostty/config
└── home/
    └── home.nix         # home-manager configuration
```

## Prerequisites

Install [Xcode](https://apps.apple.com/jp/app/xcode/id497799835) from the App Store before running the setup script.

## Setup

Clone this repository and run the bootstrap script:

```sh
git clone https://github.com/Myxogastria0808/macos-dotfiles.git
cd macos-dotfiles
bash install.sh
```

The script will:

1. Verify Xcode is installed
2. Install [Homebrew](https://brew.sh/) if not present
3. Install all packages via `brew bundle`
4. Install [Nix](https://determinate.systems/nix/) (Determinate Systems installer — flakes enabled by default)
5. Install [home-manager](https://github.com/nix-community/home-manager)
6. Symlink dotfiles to the appropriate locations
7. Run `home-manager switch` to set up Neovim (nixvim)

## Updating

### Homebrew packages

```sh
brew bundle --file=brew/Brewfile
```

### Neovim (nixvim)

```sh
home-manager switch --flake .#macos
# or use the alias:
hm
```

### Nix flake inputs

```sh
nix flake update
```
