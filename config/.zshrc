DOTFILES_DIR="$HOME/macos-dotfiles"

# ─── Completion ───────────────────────────────────────────────────────────────
autoload -Uz compinit && compinit

# ─── Plugins ──────────────────────────────────────────────────────────────────
# Oh My Zsh の代わりに Homebrew プラグインを使用
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#586e75"

# ─── direnv ───────────────────────────────────────────────────────────────────
eval "$(direnv hook zsh)"

# ─── starship ─────────────────────────────────────────────────────────────────
eval "$(starship init zsh)"

# ─── Go ───────────────────────────────────────────────────────────────────────
export PATH="$HOME/go/bin:$PATH"

# ─── uv (Python) ──────────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"

# ─── pnpm ─────────────────────────────────────────────────────────────────────
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac

# ─── Keybindings ──────────────────────────────────────────────────────────────
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^[e' edit-command-line

# ─── Functions ────────────────────────────────────────────────────────────────

# copyfile: copy file contents to clipboard
copyfile() {
	if [[ -z "${1:-}" ]]; then
		echo "Usage: copyfile <file>"
		return 1
	fi
	if [[ ! -f "$1" ]]; then
		echo "Error: File not found: $1"
		return 1
	fi
	cat "$1"
	pbcopy <"$1"
}

# copypath: copy current directory path to clipboard
copypath() {
	local result=$(pwd)
	echo "${result}"
	echo "${result}" | pbcopy
}

# mermaid: compile Mermaid diagram (.mmd) to image
mermaid() {
	local input=""
	local output=""

	__mermaid_usage() {
		cat <<EOM
Usage: mermaid <input.mmd> [-o|--output <output>]

Arguments:
    <input.mmd>          Mermaid diagram file
Options:
    -o, --output <file>  Output file (.png, .svg, .pdf; default: <input>.png)
    -h, --help           Show this help message
EOM
	}

	case "${1:-}" in
	-h | --help)
		__mermaid_usage
		return 0
		;;
	"")
		echo "Error: No input file specified."
		__mermaid_usage
		return 1
		;;
	esac

	input="$1"
	output="${input%.*}.png"

	case "${2:-}" in
	-o | --output)
		if [[ -z "${3:-}" ]]; then
			echo "Error: No output file specified."
			__mermaid_usage
			return 1
		fi
		output="$3"
		;;
	esac

	if [[ "$input" != *.mmd ]]; then
		echo "Error: Input file must be a .mmd file: $input"
		return 1
	fi

	if [[ ! -f "$input" ]]; then
		echo "Error: File not found: $input"
		return 1
	fi

	if [[ "$output" != *.png && "$output" != *.svg && "$output" != *.pdf ]]; then
		echo "Error: Output must be .png, .svg, or .pdf: $output"
		return 1
	fi

	if [[ -f "$output" ]]; then
		echo "$output already exists. Overwrite? (y/N)"
		read -r answer
		if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
			echo "Overwrite cancelled."
			return 0
		fi
	fi

	echo "Generating diagram: $output"
	mmdc -i "$input" -o "$output"
}

# shell: zsh keyboard shortcuts cheatsheet
shell() {
	local BOLD="\e[1m"
	local RESET="\e[0m"
	local CYAN="\e[36m"
	local YELLOW="\e[33m"
	local GREEN="\e[32m"
	local MAGENTA="\e[35m"
	local DIM="\e[2m"
	echo ""
	echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════╗${RESET}"
	echo -e "${BOLD}${CYAN}║           zsh Keyboard Shortcuts Cheatsheet          ║${RESET}"
	echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════════╝${RESET}"
	echo ""
	echo -e "${BOLD}${YELLOW}  Cursor Movement${RESET}"
	echo -e "${DIM}  ──────────────────────────────────────────────────────${RESET}"
	echo ""
	echo -e "  ${BOLD}Ctrl+A${RESET}  Move to beginning of line"
	echo -e "  ${DIM}  \$ git commit -m \"fix bug\"${RESET}"
	echo -e "  ${GREEN}    ^${RESET}"
	echo -e "  ${GREEN}    Ctrl+A moves here${RESET}"
	echo ""
	echo -e "  ${BOLD}Ctrl+E${RESET}  Move to end of line"
	echo -e "  ${DIM}  \$ git commit -m \"fix bug\"${RESET}"
	echo -e "  ${GREEN}                           ^${RESET}"
	echo -e "  ${GREEN}                           Ctrl+E moves here${RESET}"
	echo ""
	echo -e "  ${BOLD}Alt+F / Alt+B${RESET}  Move forward / backward one word"
	echo -e "  ${DIM}  \$ git commit -m \"fix bug\"${RESET}"
	echo -e "  ${GREEN}    ^   ^       ^  ^   ^   ${RESET}"
	echo -e "  ${GREEN}    Jump word by word${RESET}"
	echo ""
	echo -e "  ${BOLD}Alt+>${RESET}  Insert history entry at cursor position"
	echo -e "  ${DIM}  \$ git commit  \"fix bug\"${RESET}"
	echo -e "  ${GREEN}               ^${RESET}"
	echo -e "  ${GREEN}               Selected history entry is inserted here${RESET}"
	echo ""
	echo -e "${BOLD}${YELLOW}  Text Editing${RESET}"
	echo -e "${DIM}  ──────────────────────────────────────────────────────${RESET}"
	echo ""
	printf "  ${BOLD}%-16s${RESET} %s\n" "Ctrl+K" "Delete from cursor to end of line"
	echo -e "  ${DIM}  \$ git commit -m \"fix bug\"${RESET}"
	echo -e "  ${DIM}            ^${RESET}"
	echo -e "  ${MAGENTA}            ├──────────────┤ ← deleted${RESET}"
	echo ""
	printf "  ${BOLD}%-16s${RESET} %s\n" "Ctrl+U" "Delete entire line"
	echo -e "  ${DIM}  \$ git commit -m \"fix bug\"${RESET}"
	echo -e "  ${MAGENTA}   ├───────────────────────┤ ← all deleted${RESET}"
	echo ""
	printf "  ${BOLD}%-16s${RESET} %s\n" "Ctrl+T" "Swap the two characters before cursor"
	echo -e "  ${DIM}  \$ git commit -m \"fxi bug\"${RESET}"
	echo -e "  ${DIM}                    ^^ cursor${RESET}"
	echo -e "  ${GREEN}  \$ git commit -m \"fix bug\"${RESET}"
	echo -e "  ${GREEN}                    ^^${RESET}"
	echo ""
	printf "  ${BOLD}%-16s${RESET} %s\n" "Alt+T" "Swap the two words before cursor"
	echo -e "  ${DIM}  \$ git commit -m \"fix bug\"${RESET}"
	echo -e "  ${DIM}    ^───^ cursor${RESET}"
	echo -e "  ${GREEN}  \$ commit git -m \"fix bug\"${RESET}"
	echo -e "  ${GREEN}    ^──────^${RESET}"
	echo ""
	printf "  ${BOLD}%-16s${RESET} %s\n" "Ctrl+_" "Undo last edit"
	echo ""
	echo -e "${BOLD}${YELLOW}  Other${RESET}"
	echo -e "${DIM}  ──────────────────────────────────────────────────────${RESET}"
	echo ""
	printf "  ${BOLD}%-16s${RESET} %s\n" "Ctrl+L" "Clear screen (history preserved)"
	printf "  ${BOLD}%-16s${RESET} %s\n" "Alt+E" "Edit current input in editor"
	echo ""
}

# peco-src: fuzzy repository switcher using ghq + peco, bound to Ctrl+g
# Ref: https://zenn.dev/oreo2990/articles/13c80cf34a95af
peco-src() {
	local selected_dir=$(ghq list -p | peco --prompt="repositories >" --query "$LBUFFER")
	if [[ -n "$selected_dir" ]]; then
		BUFFER="cd ${selected_dir}"
		zle accept-line
	fi
	zle clear-screen
}
zle -N peco-src
bindkey '^g' peco-src

# ─── Functions (cont.) ────────────────────────────────────────────────────────

# brew-update: upgrade all packages, dump Brewfile, and push to remote
brew-update() {
	brew update
	brew upgrade
	brew bundle dump --force --file="$DOTFILES_DIR/brew/Brewfile"
	git -C "$DOTFILES_DIR" add brew/Brewfile
	git -C "$DOTFILES_DIR" commit -m "chore: update Brewfile"
	git -C "$DOTFILES_DIR" push
}

# ollama-serve: set OLLAMA_HOST to Tailscale IP via launchctl
ollama-serve() {
	if ! command -v ollama &>/dev/null; then
		echo "Error: Ollama is not installed."
		return 1
	fi

	if ! curl -sf http://localhost:11434 &>/dev/null; then
		echo "Error: Ollama is not running. Please start Ollama first."
		return 1
	fi

	if ! command -v tailscale &>/dev/null; then
		echo "Error: Tailscale is not installed."
		return 1
	fi

	local tailscale_ip
	tailscale_ip=$(tailscale ip -4)
	if [[ -z "$tailscale_ip" ]]; then
		echo "Error: Could not retrieve Tailscale IPv4 address."
		return 1
	fi

	launchctl setenv OLLAMA_HOST "$tailscale_ip"
	echo "OLLAMA_HOST set to $tailscale_ip"
}

# ─── Aliases ──────────────────────────────────────────────────────────────────
# Navigation
alias ..='cd ../'
alias ...='cd ../../'
alias ....='cd ../../../'
# Modern CLI replacements
alias ls='eza'
alias ll='eza -alh'
alias tree='eza --tree'
alias size='fd --size'
alias diff='delta --side-by-side'
alias neofetch='fastfetch'
# Nix
alias nix-develop='nix develop -c $SHELL'
alias hm='home-manager switch --flake "$DOTFILES_DIR#macos"'
alias gc='nix-collect-garbage --delete-old'
# Tools
alias t='typst watch'
alias cf-net='open https://speed.cloudflare.com/'
alias g='lazygit'
alias d='lazydocker'
alias clone='ghq get'
alias clock='tty-clock -c -s'
alias music='cava'
alias tetris='bastet'

