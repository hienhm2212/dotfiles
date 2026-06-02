# Little Fox Emacs

My personal Emacs configuration, written in Org-mode for literate programming.

## Features

- **Org-mode based config** - `lf-config.org` tangles to elisp
- **Fast startup** - Early init optimizations, deferred loading
- **Modern completion** - Vertico, Corfu, Orderless, Consult, Embark
- **LSP support** - Eglot with TypeScript, Go, Python, Ruby (Solargraph)
- **Tree-sitter** - Modern syntax highlighting for all major languages
- **Visual enhancements** - Indent bars, Nyan mode, doom-themes
- **Ruby development** - Solargraph LSP, inf-ruby REPL, RSpec, Rubocop formatting
- **Note-taking** - Denote for Zettelkasten-style notes
- **Git** - Magit with todos and diff highlighting
- **Org-mode** - Agenda, capture, babel, presentations

## Structure

```
~/.emacs.d/
├── init.el          # Bootstrap, loads lf-config.org
├── early-init.el    # Startup optimizations (GC, UI)
├── lf-config.org    # Main config (literate org-mode)
└── private.el       # Private settings (not tracked)
```

## Key Packages

| Category | Packages |
|----------|----------|
| Completion | vertico, corfu, orderless, consult, embark, cape |
| UI | doom-modeline, doom-themes, nerd-icons, indent-bars, nyan-mode |
| Languages | eglot, treesit, apheleia (formatting) |
| Ruby | inf-ruby, rspec-mode, solargraph, rubocop |
| Notes | denote, consult-denote |
| Git | magit, diff-hl, magit-todos |
| Org | org-bullets, org-appear, org-present, org-re-reveal |

## Keybindings

### Notes (Denote)
| Key | Action |
|-----|--------|
| `C-c n n` | New note |
| `C-c n o` | Open or create note |
| `C-c n f` | Find note |
| `C-c n l` | Insert link |
| `C-c n b` | Show backlinks |

### Ruby Development
| Key | Action |
|-----|--------|
| `C-c C-s` | Start Ruby REPL (inf-ruby) |
| `C-c C-r` | Send region to REPL |
| `C-c C-b` | Send buffer to REPL |
| `M-.` | Go to definition (LSP) |
| `M-,` | Go back |
| `C-h .` | Show documentation at point |

### Navigation
| Key | Action |
|-----|--------|
| `C-x b` | Switch buffer (consult) |
| `M-g g` | Go to line |
| `M-s l` | Search line |
| `M-s r` | Ripgrep |

## Quick Install

### One-line Install (Automated)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/hienhm2212/my-emacs/main/install.sh)
```

This will:
- ✅ Install Emacs 29+ (if not present)
- ✅ Install system dependencies (ripgrep, fonts, etc.)
- ✅ Clone this configuration
- ✅ Install language servers (TypeScript, Python, Go, Ruby)
- ✅ Set up development tools

### Manual Install

```bash
# Backup existing config (if any)
mv ~/.emacs.d ~/.emacs.d.backup

# Clone this config
git clone https://github.com/hienhm2212/my-emacs.git ~/.emacs.d

# Install dependencies (example for Ubuntu/Debian)
sudo apt install emacs29 ripgrep fd-find fonts-jetbrains-mono

# Launch Emacs (packages will auto-install)
emacs
```

## Post-Installation

After first launch:

1. **Install Nerd Fonts**: `M-x nerd-icons-install-fonts`
2. **Configure private settings**: Edit `~/.emacs.d/private.el`
3. **Wait for packages**: First launch takes ~2-5 minutes to compile

## Requirements

- Emacs 29+ (native-comp recommended)
- Git, ripgrep, fd
- Fonts: JetBrains Mono, Iosevka (auto-installed by script)

### Optional Language Tools

- **Ruby**: `gem install solargraph rubocop`
- **TypeScript/JavaScript**: `npm install -g typescript-language-server`
- **Python**: `pip3 install 'python-lsp-server[all]'`
- **Go**: `go install golang.org/x/tools/gopls@latest`
