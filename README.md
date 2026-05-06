# macos-dotfiles

macOS dotfiles for Apple Silicon (M-series) Macs.

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
├── ollama.sh            # Pull Ollama models
├── flake.nix            # Nix flake (home-manager standalone)
├── brew/
│   └── Brewfile         # Homebrew packages
├── config/
│   ├── .zshrc           # → ~/.zshrc
│   ├── .zprofile        # → ~/.zprofile
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
    ├── browser.sh       # Default browser (Google Chrome)
    ├── dock.sh          # Dock layout and pinned apps
    ├── startup.sh       # Login items (Ollama, Notion, Notion Calendar)
    ├── nix.sh           # Nix installer (Determinate Systems)
    ├── tailscale.sh     # Tailscale install + connect with SSH flag
    ├── hostname.sh      # Computer name / LocalHostName / HostName
    └── vnc.sh           # Remote Management (VNC)
```

## Prerequisites

- **macOS 26** (Apple Silicon) — this is the only supported OS version
- Install [Xcode](https://apps.apple.com/jp/app/xcode/id497799835) from the App Store before running the setup script.
- Grant **Full Disk Access** to your terminal app (`System Settings > Privacy & Security > Full Disk Access`) — required for running `mouse.sh`.

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
2. Verify Full Disk Access for the terminal app (exits with instructions if missing)
3. Configure Git (`user.name`, `user.email`)
4. Install [Homebrew](https://brew.sh/) if not present
5. Install all packages via `brew bundle`
6. Install [Nix](https://determinate.systems/nix/) (Determinate Systems — flakes enabled by default)
7. Symlink dotfiles (`~/.zshrc`, `~/.zprofile`, `~/.config/starship.toml`, `~/.config/ghostty/config`)
8. Install language toolchains: Rust, Python, R, Julia, Haskell, OCaml, Lean4
9. Run `home-manager switch` to set up Neovim (nixvim)
10. Apply macOS system settings (mouse, menu bar, Finder, keyboard, IME, default browser, Dock, startup items, Tailscale)
11. Configure hostname, VNC (interactive)

### After running install.sh

The following steps require manual action:

**System Settings > Privacy & Security:**

| Permission       | Target   | Purpose            |
| ---------------- | -------- | ------------------ |
| Screen Recording | ARDAgent | VNC screen sharing |
| Accessibility    | ARDAgent | VNC remote control |

ARDAgent path: `/System/Library/CoreServices/RemoteManagement/ARDAgent.app`

**macSKK setup** (`TISEnableInputSource` does not persist on macOS Sequoia):

1. System Settings > Keyboard > Input Sources > **+** → add macSKK
2. Menu bar input menu → macSKK → **Preferences** → enable all 17 dictionaries in the Dictionary settings

### Ollama models

Pull LLM models separately after Ollama is running:

```sh
sh ollama.sh
```

Models: qwen3.5 (0.8b / 2b / 4b / 9b / 27b / 35b / 122b), qwen3.6 (27b / 35b)

## macOS Configuration Scripts

Each script in `scripts/` is independently executable and idempotent. All scripts source `scripts/_lib.sh` for shared logging.

---

### `mouse.sh` — Mouse cursor size

| Setting     | Value  | defaults domain             | Key                     |
| ----------- | ------ | --------------------------- | ----------------------- |
| Cursor size | `2.5×` | `com.apple.universalaccess` | `mouseDriverCursorSize` |

**Requires**: Full Disk Access for the terminal app.

---

### `menubar.sh` — Menu bar clock

| Setting      | Value               | defaults domain             | Key           |
| ------------ | ------------------- | --------------------------- | ------------- |
| Clock format | `EEE d MMM H:mm:ss` | `com.apple.menuextra.clock` | `DateFormat`  |
| Show seconds | `true`              | `com.apple.menuextra.clock` | `ShowSeconds` |

The clock displays as e.g. `Tue 6 May 14:35:22` — day-of-week, date, 24-hour time with seconds.

---

### `finder.sh` — Finder display

| Setting                | Value  | defaults domain    | Key                      |
| ---------------------- | ------ | ------------------ | ------------------------ |
| Show hidden files      | `true` | `com.apple.finder` | `AppleShowAllFiles`      |
| Always show extensions | `true` | `NSGlobalDomain`   | `AppleShowAllExtensions` |

A reboot (or manual Finder restart) is required to apply the changes.

---

### `keyboard.sh` — Key repeat speed

| Setting              | Value | defaults domain  | Key                |
| -------------------- | ----- | ---------------- | ------------------ |
| Key repeat rate      | `2`   | `NSGlobalDomain` | `KeyRepeat`        |
| Initial repeat delay | `20`  | `NSGlobalDomain` | `InitialKeyRepeat` |

---

### `ime.sh` — macSKK Japanese input method

Downloads all standard SKK dictionaries from [skk-dev/dict](https://github.com/skk-dev/dict) and places them in the macSKK Dictionaries folder.

**What is automated:**

- Launches macSKK once to initialize its app container (if not yet initialized)
- Downloads 17 dictionaries and converts EUC-JP files to UTF-8

**What requires manual setup (macOS Sequoia limitation):**

- `TISEnableInputSource()` via TIS API does not persist to `AppleEnabledInputSources` on macOS Sequoia — input source registration must be done through System Settings
- macSKK auto-detects files placed in the Dictionaries folder but does not enable them automatically — each dictionary must be enabled manually in macSKK Settings

After running, complete setup in this order:

1. **System Settings > Keyboard > Input Sources > +** → add macSKK
2. **Menu bar input menu → macSKK → Preferences** → enable all 17 dictionaries in the Dictionary settings

**Dictionaries downloaded** (saved to `~/Library/Containers/net.mtgto.inputmethod.macSKK/Data/Documents/Dictionaries/` as UTF-8):

| Dictionary                | Contents                             |
| ------------------------- | ------------------------------------ |
| `SKK-JISYO.L`             | General-purpose large dictionary     |
| `SKK-JISYO.propernoun`    | Proper nouns                         |
| `SKK-JISYO.jinmei`        | Japanese personal names              |
| `SKK-JISYO.fullname`      | Full names                           |
| `SKK-JISYO.station`       | Railway station names                |
| `SKK-JISYO.geo`           | Geographic names                     |
| `SKK-JISYO.okinawa`       | Okinawan vocabulary and proper nouns |
| `SKK-JISYO.law`           | Legal terminology                    |
| `SKK-JISYO.mazegaki`      | Mixed kana/kanji words               |
| `SKK-JISYO.emoji`         | Emoji completions                    |
| `SKK-JISYO.china_taiwan`  | Chinese and Taiwanese place names    |
| `SKK-JISYO.JIS2`          | JIS level-2 kanji                    |
| `SKK-JISYO.JIS2004`       | JIS X 0213:2004 kanji                |
| `SKK-JISYO.JIS3_4`        | JIS level 3 and 4 kanji              |
| `SKK-JISYO.itaiji`        | Variant character forms              |
| `SKK-JISYO.itaiji.JIS3_4` | Variant forms for JIS level 3/4      |
| `SKK-JISYO.zipcode`       | Japanese postal codes                |

Dictionaries are placed as UTF-8 files. macSKK auto-detects them on next launch but leaves them disabled — enable each one manually in macSKK Settings > Dictionaries.

---

### `browser.sh` — Default browser

Sets Google Chrome as the system default browser using [`defaultbrowser`](https://github.com/nicowillis/defaultbrowser).

The macOS confirmation dialog is dismissed automatically via AppleScript — no manual interaction required.

**Requires**: `defaultbrowser` (installed via Brewfile).

---

### `dock.sh` — Dock layout

| Setting      | Value    | defaults domain  | Key            |
| ------------ | -------- | ---------------- | -------------- |
| Position     | `bottom` | `com.apple.dock` | `orientation`  |
| Icon size    | `48 px`  | `com.apple.dock` | `tilesize`     |
| Auto-hide    | `false`  | `com.apple.dock` | `autohide`     |
| Show recents | `false`  | `com.apple.dock` | `show-recents` |

**Pinned apps** (in order, set via `dockutil`):

1. Launchpad
2. System Settings
3. Google Chrome
4. Discord
5. Slack
6. Ghostty
7. Claude
8. Codex
9. Ollama
10. Notion
11. Notion Calendar
12. Bitwarden

All existing Dock items are removed before adding the pinned apps above.

**Requires**: `dockutil` (installed via Brewfile).

---

### `startup.sh` — Login items

Adds the following apps as hidden login items (start at login, no window shown):

| App             | Path                                |
| --------------- | ----------------------------------- |
| Ollama          | `/Applications/Ollama.app`          |
| Notion          | `/Applications/Notion.app`          |
| Notion Calendar | `/Applications/Notion Calendar.app` |

Uses `osascript` / System Events to add login items. Already-registered items are skipped. macOS prompts for Automation permission automatically on first run.

---

### `nix.sh` — Nix installation

Installs [Nix](https://determinate.systems/nix/) via the Determinate Systems installer if not already present. Flakes are enabled by default.

```sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm
```

Skipped if `nix` is already in `$PATH`.

---

### `tailscale.sh` — Tailscale VPN

Installs Tailscale from source via `go install` and connects to the tailnet.

| Step                  | Command                                                          |
| --------------------- | ---------------------------------------------------------------- |
| Install CLI binaries  | `go install tailscale.com/cmd/tailscale@latest` (+ `tailscaled`) |
| Install system daemon | `tailscaled install-system-daemon` (via `sudo`)                  |
| Connect               | `tailscale up --ssh --accept-routes`                             |

Options enabled on connect:

- `--ssh`: enables Tailscale SSH (no separate SSH key management needed within the tailnet)
- `--accept-routes`: accept subnet routes advertised by other tailnet nodes

Skipped at each step if already installed / already connected.

**Requires**: Go installed (via Brewfile).

---

### `hostname.sh` — Machine name (interactive)

Sets three hostname identifiers interactively, showing current values first:

| Identifier      | Where it appears                     | Command                           |
| --------------- | ------------------------------------ | --------------------------------- |
| `ComputerName`  | Finder sidebar, AirDrop display name | `sudo scutil --set ComputerName`  |
| `LocalHostName` | Bonjour `.local` hostname            | `sudo scutil --set LocalHostName` |
| `HostName`      | Shell prompt, kernel hostname        | `sudo scutil --set HostName`      |

`LocalHostName` and `HostName` are always set to the same value. Valid format: alphanumeric and hyphens, must not start or end with a hyphen.

Either prompt can be left empty to skip that setting.

---

### `vnc.sh` — Remote Management / VNC (interactive)

Activates macOS Remote Management (ARD/VNC) and sets a VNC password.

Prompts for a VNC password; skipped entirely if left empty.

| Step                        | Command                                                                                                                       |
| --------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| Unload screen sharing plist | `sudo launchctl unload -w com.apple.screensharing.plist`                                                                      |
| Activate ARD + set password | `kickstart -activate -configure -access -on -privs -all -clientopts -setvnclegacy -vnclegacy yes -clientopts -setvncpw -vncpw <password> -restart -agent` |

Uses legacy VNC protocol (`-vnclegacy yes`) for compatibility with standard VNC clients.

ARDAgent path: `/System/Library/CoreServices/RemoteManagement/ARDAgent.app`

**Requires** (must grant manually after running):

- `System Settings > Privacy & Security > Screen Recording` → add ARDAgent
- `System Settings > Privacy & Security > Accessibility` → add ARDAgent

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

