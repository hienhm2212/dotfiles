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
| tmux       | ~/.config/tmux/                              |
| yazi       | ~/.config/yazi/yazi.toml                     |
| starship   | ~/.config/starship.toml                      |

## Quick start

```bash
git clone git@github.com:hienhm2212/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
make install   # packages for this OS + stow + fish as login shell
```

`install.sh` detects the OS:

- **macOS** — installs Homebrew if missing, then `brew bundle` from `Brewfile`
  (Apple Silicon and Intel both supported), then the tide prompt via fisher.
- **Ubuntu/Debian** — apt packages, symlinks `fdfind`/`batcat` to `fd`/`bat`
  in `~/.local/bin`, installs starship and mise via their install scripts.
  yazi and ghostty are not in apt; install them separately.

Fonts are not installed automatically: Ghostty expects *BerkeleyMono Nerd Font*.

If stow reports a conflict, an existing file (e.g. `~/.config/fish/config.fish`)
is in the way — back it up and remove it, then `make stow` again.

## How it works

Stow mirrors each package directory into $HOME as symlinks.

## Daily commands

```bash
make           # list targets
make install   # install packages for this OS, then stow
make stow      # symlink all packages
make unstow    # remove all symlinks
make restow    # re-stow after adding files
make dry-run   # preview what stow would do
make update    # git pull + restow
```

## Shell (Fish)

Config is split into conf.d/ files loaded in order:

- 00_platform.fish  — OS detection
- 01_exports.fish   — PATH, environment variables
- 02_go.fish        — Go toolchain
- 03_tools.fish     — fzf, bat, zoxide, yazi, ripgrep
- 04_aliases.fish   — aliases and git abbreviations
- 05_starship.fish  — prompt init

Functions in fish/functions/ — one file per function (the file name must
match the function name, or fish won't autoload it).

Linux-only commands (`free`, `fs`, `localip`, `ports`, clipboard) are aliased
per `$PLATFORM`, so the same config works on macOS.

Machine-local settings (secrets, work paths) go in
`~/.config/fish/config-local.fish` — sourced last, never stowed or committed.

### Prompt

- **Linux** — starship (`starship/.config/starship.toml`).
- **macOS** — [tide](https://github.com/IlanCosman/tide), installed with fisher.
  `05_starship.fish` skips starship whenever tide is installed, so the two never
  fight over `fish_prompt`. Tide's settings live in fish universal variables
  (`~/.config/fish/fish_variables`), which stay on the machine — re-run
  `tide configure` on a new Mac.

Stow runs with `--no-folding`, so `~/.config/fish` is a real directory with
symlinked files: fisher plugins and `fish_variables` stay out of the repo
(`fish/.stow-local-ignore`).

## tmux

Modelled on [craftzdog's](https://github.com/craftzdog/dotfiles-public) setup
(prefix `C-t`, tmux-pain-control, popups, powerline statusline), recoloured
Catppuccin Macchiato. Ghostty no longer manages splits/tabs — tmux does.
`make install` clones [TPM](https://github.com/tmux-plugins/tpm) and installs
the plugins; on an existing machine run `prefix I` inside tmux.

Start: `t` (fish abbr) attaches or creates a session named after `$PWD`.
`ide` splits the window into editor + 3 terminals.

| Keys (after `C-t`) | Action                                          |
|--------------------|-------------------------------------------------|
| `C-t`              | send a literal C-t (transpose-chars)            |
| `3` / `2`          | split right / down (like Emacs `C-x 3`/`C-x 2`) |
| `\|` `-`           | split right / down (pain-control)               |
| `h j k l`          | move between panes                              |
| `H J K L`          | resize pane                                     |
| `z` / `f`          | zoom pane                                       |
| `e`                | spread panes evenly                             |
| `X`                | kill every other pane                           |
| `c` `n` `p` `1..9` | new / next / previous / go to window            |
| `C-S-←` `C-S-→`    | move window left / right (no prefix)            |
| `u` / `[`          | copy-mode (Emacs keys; `M-w` or `y` copies)     |
| `g`                | Magit popup for the pane's repo (`C-x C-c` exits)|
| `F`                | yazi popup                                      |
| `y`                | Claude Code popup, one session per directory    |
| `o`                | open the directory in Finder / file manager     |
| `r`                | reload config                                   |
| `d`                | detach                                          |

Copies go to the system clipboard through OSC 52 (Ghostty `clipboard-write`),
locally and over SSH.

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
- Terminal: Ghostty + tmux
- Editor: Emacs
- Prompt: Starship
- File manager: Yazi
- Version manager: mise
- Theme: Catppuccin everywhere
