#!/usr/bin/env zsh
set -euo pipefail
source "${0:a:h}/_lib.sh"

if ! command -v dockutil &>/dev/null; then
	err "'dockutil' not found. Install it with: brew install dockutil"
	exit 1
fi

echo "==> Dock"
defaults write com.apple.dock orientation -string "bottom"
defaults write com.apple.dock tilesize -int 48
defaults write com.apple.dock autohide -bool false
defaults write com.apple.dock show-recents -bool false
ok "Position → bottom | Size → 48 | Autohide → off | Show recents → off"

dockutil --remove all --no-restart

_apps=(
	"Launchpad:/System/Applications/Apps.app"
	"System Settings:/System/Applications/System Settings.app"
	"Google Chrome:/Applications/Google Chrome.app"
	"Discord:/Applications/Discord.app"
	"Slack:/Applications/Slack.app"
	"Ghostty:/Applications/Ghostty.app"
	"Claude:/Applications/Claude.app"
	"Codex:/Applications/Codex.app"
	"Ollama:/Applications/Ollama.app"
	"Notion:/Applications/Notion.app"
	"Notion Calendar:/Applications/Notion Calendar.app"
	"Bitwarden:/Applications/Bitwarden.app"
)
for _entry in "${_apps[@]}"; do
	_name="${_entry%%:*}"
	_path="${_entry#*:}"
	dockutil --add "$_path" --no-restart
	ok "Pinned → $_name"
done
unset _apps _entry _name _path

killall Dock
ok "Dock restarted"

