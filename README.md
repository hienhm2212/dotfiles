# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).
Works on Ubuntu/Linux and macOS.

## What's managed

| Package    | Config location                              |
|------------|----------------------------------------------|
| fish       | ~/.config/fish/                              |
| emacs      | ~/.emacs.d/                                  |
| git        | ~/.gitconfig, ~/.gitignore_global            |
| ghostty    | ~/.config/ghostty/config                     |
| yazi       | ~/.config/yazi/yazi.toml                     |
| starship   | ~/.config/starship.toml                      |

## Quick start

```bash
git clone git@github.com:hienhm2212/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
bash install.sh
```

## How it works

Stow mirrors each package directory into $HOME as symlinks.

## Daily commands

```bash
make stow      # symlink all packages
make unstow    # remove all symlinks
make restow    # re-stow after adding files
make update    # git pull + restow
```

## Shell (Fish)

Config is split into conf.d/ files loaded in order:

- 00_platform.fish  — OS detection
- 01_exports.fish   — PATH, environment variables
- 02_go.fish        — Go and Flutter
- 03_tools.fish     — fzf, bat, zoxide, yazi, ripgrep
- 04_aliases.fish   — aliases and git abbreviations
- 05_starship.fish  — prompt init

Functions in fish/functions/ — one file per function.

## Emacs

Little Fox Emacs — modular config using elpaca package manager.

Modules in ~/.emacs.d/lisp/:

- lf-core       — elpaca bootstrap, base defaults
- lf-ui         — theme, fonts, modeline
- lf-completion — vertico, consult, corfu, embark
- lf-prog       — eglot LSP, treesit, projectile
- lf-lang-go    — Go + gopls
- lf-lang-ruby  — Ruby + solargraph
- lf-lang-rust  — Rust + rust-analyzer
- lf-lang-web   — JS/TS/React
- lf-org        — Org-mode
- lf-keys       — keybindings

Language servers needed on a fresh machine:

```bash
go install golang.org/x/tools/gopls@latest
gem install solargraph
rustup component add rust-analyzer
npm install -g typescript-language-server
```

## SSH

Only ~/.ssh/config is symlinked. Keys are never stored in dotfiles.

Generate a key on a fresh machine:

```bash
ssh-keygen -t ed25519 -C "you@example.com"
ssh-add ~/.ssh/id_ed25519
```

## macOS

```bash
brew bundle --file=os/macos/Brewfile
bash install.sh stow
```

## Tools

- Shell: Fish
- Terminal: Ghostty
- Editor: Emacs
- Prompt: Starship
- File manager: Yazi
- Version manager: mise
- Theme: Catppuccin everywhere
