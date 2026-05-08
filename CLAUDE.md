# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A macOS dotfiles bootstrap for Apple Silicon. Running `bash install.sh` sets up a new Mac from scratch. The scripts in `scripts/` are also runnable independently.

## Key commands

```sh
# Full bootstrap (new machine)
./install.sh

# Apply a single macOS config script
./scripts/dock.sh
./scripts/keyboard.sh
# etc.

# Sync Brewfile and push
brew-update   # alias in .zshrc

# Apply Nix/home-manager config (nixvim)
hm            # alias: home-manager switch --flake "$DOTFILES_DIR#macos"

# Pull Ollama models
bash ollama.sh
```

## Architecture

### install.sh

Linear bootstrap script. Sections in order:

1. Xcode check (hard exit if missing)
2. Full Disk Access check (hard exit with instructions if missing)
3. Git config (interactive, shows current values first)
4. Homebrew install + `brew bundle`
5. Nix install (Determinate Systems)
6. Dotfile symlinks
7. Language toolchains — each guarded to skip if already installed:
   - Rust (`~/.cargo`), Python (`uv`), R (`rig`), Julia (`juliaup`), Haskell (`~/.ghcup/bin/ghc`), OCaml (`~/.opam`), Lean4 (`~/.elan/bin/lean`)
   - Go is installed via Brewfile; no extra step needed
8. `home-manager switch` (applies nixvim)
9. Calls each `scripts/*.sh` in sequence
10. Final summary with required manual actions

### scripts/

Each script is self-contained and independently executable. All source `scripts/_lib.sh` for shared logging (`ok`, `skip`, `err`, `action`).

| Script                                                         | Requires                                        |
| -------------------------------------------------------------- | ----------------------------------------------- |
| `mouse.sh`, `menubar.sh`, `finder.sh`, `keyboard.sh`, `ime.sh` | `defaults` (always present)                     |
| `browser.sh`                                                   | `defaultbrowser` (from Brewfile)                |
| `dock.sh`                                                      | `dockutil` (from Brewfile)                      |
| `startup.sh`                                                   | `osascript` (always present)                    |
| `tailscale.sh`                                                 | `go` (from Brewfile), installs via `go install` |
| `hostname.sh`                                                  | `scutil` (always present), interactive          |

### Logging conventions (`scripts/_lib.sh`)

```
✓  green  — ok()     success
–  yellow — skip()   already done, skipped
✗  red    — err()    failure (stderr)
!  magenta — action() manual user action required
```

### Nix

`flake.nix` is home-manager standalone (no NixOS). Target: `aarch64-darwin`, username `hello`. The only Nix-managed package is nixvim (pulled from an external flake). Everything else is Homebrew.

## Conventions

- Shell scripts use `#!/usr/bin/env zsh` + `set -euo pipefail`
- Guards before every language install to ensure idempotency
- `DOTFILES_DIR` is set in `.zshrc` and in `install.sh` (via `${BASH_SOURCE[0]}`) — never hardcode paths
- `brew-update` (`.zshrc` function) = `brew bundle dump --force` + git commit + push

