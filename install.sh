#!/usr/bin/env bash
# Bootstrap: install packages for this OS, stow configs, set fish as login shell.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_BIN="$HOME/.local/bin"

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m==>\033[0m %s\n' "$*" >&2; }

install_macos() {
    if ! command -v brew >/dev/null 2>&1; then
        info "Installing Homebrew"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    # Apple Silicon installs to /opt/homebrew, Intel to /usr/local
    for brew in /opt/homebrew/bin/brew /usr/local/bin/brew; do
        if [[ -x "$brew" ]]; then
            eval "$("$brew" shellenv)"
            break
        fi
    done

    info "Installing packages from Brewfile"
    brew bundle --file="$DOTFILES/Brewfile"
}

install_tide() {
    # fisher is a fish function shipped by the Homebrew formula
    if ! fish -c 'functions -q tide' 2>/dev/null; then
        info "Installing tide prompt"
        fish -c 'fisher install ilancosman/tide@v6'
    fi
}

install_linux() {
    if ! command -v apt-get >/dev/null 2>&1; then
        warn "Only apt-based distros are supported; install packages manually"
        return
    fi

    info "Installing apt packages"
    sudo apt-get update
    sudo apt-get install -y fish stow tmux git curl xclip fzf ripgrep fd-find bat zoxide

    # Not packaged on older Ubuntu releases - install what's available
    for pkg in eza git-delta; do
        sudo apt-get install -y "$pkg" || warn "apt has no $pkg; install it manually"
    done

    mkdir -p "$LOCAL_BIN"

    # Debian/Ubuntu rename these binaries to avoid name clashes
    for pair in fdfind:fd batcat:bat; do
        local src="${pair%%:*}" dst="${pair##*:}"
        if command -v "$src" >/dev/null 2>&1 && ! command -v "$dst" >/dev/null 2>&1; then
            ln -sf "$(command -v "$src")" "$LOCAL_BIN/$dst"
        fi
    done

    if ! command -v starship >/dev/null 2>&1; then
        info "Installing starship"
        curl -sS https://starship.rs/install.sh | sh -s -- -y -b "$LOCAL_BIN"
    fi
    if ! command -v mise >/dev/null 2>&1; then
        info "Installing mise"
        curl -fsSL https://mise.run | sh
    fi

    for tool in yazi ghostty emacs; do
        command -v "$tool" >/dev/null 2>&1 || warn "$tool not installed; see its docs (emacs: emacs/.emacs.d/install.sh)"
    done
}

set_login_shell() {
    local fish_path
    fish_path="$(command -v fish || true)"
    if [[ -z "$fish_path" ]] || [[ "$SHELL" == "$fish_path" ]]; then
        return
    fi
    info "Setting fish as login shell"
    grep -qxF "$fish_path" /etc/shells || echo "$fish_path" | sudo tee -a /etc/shells >/dev/null
    chsh -s "$fish_path" || warn "chsh failed; run: chsh -s $fish_path"
}

case "$(uname -s)" in
    Darwin) install_macos ;;
    Linux) install_linux ;;
    *) warn "Unsupported OS: $(uname -s)"; exit 1 ;;
esac

info "Stowing dotfiles"
make -C "$DOTFILES" stow

# After stow, so fisher writes into the real ~/.config/fish, not the repo
[[ "$(uname -s)" == Darwin ]] && install_tide

set_login_shell

info "Done. Open a new terminal or run: exec fish"
