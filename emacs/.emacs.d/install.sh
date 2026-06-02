#!/usr/bin/env bash
###############################################################################
# Little Fox Emacs - Automated Installation Script
# Author: hienhm2212
# Repo: https://github.com/hienhm2212/my-emacs
###############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="https://github.com/hienhm2212/my-emacs.git"
EMACS_DIR="$HOME/.emacs.d"
BACKUP_DIR="$HOME/.emacs.d.backup.$(date +%Y%m%d_%H%M%S)"

###############################################################################
# Helper Functions
###############################################################################

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

###############################################################################
# OS Detection
###############################################################################

detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command_exists apt; then
            OS="ubuntu"
            PKG_MANAGER="apt"
        elif command_exists dnf; then
            OS="fedora"
            PKG_MANAGER="dnf"
        elif command_exists pacman; then
            OS="arch"
            PKG_MANAGER="pacman"
        else
            OS="linux"
            PKG_MANAGER="unknown"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        PKG_MANAGER="brew"
    else
        OS="unknown"
        PKG_MANAGER="unknown"
    fi

    print_info "Detected OS: $OS"
}

###############################################################################
# Emacs Installation
###############################################################################

install_emacs() {
    print_header "Installing Emacs"

    if command_exists emacs; then
        EMACS_VERSION=$(emacs --version | head -n1)
        print_warning "Emacs already installed: $EMACS_VERSION"

        # Check version
        MAJOR_VERSION=$(emacs --version | head -n1 | grep -oP '\d+' | head -n1)
        if [ "$MAJOR_VERSION" -lt 29 ]; then
            print_warning "Emacs version < 29. Tree-sitter features may not work."
            read -p "Update Emacs? (y/n) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                return
            fi
        else
            return
        fi
    fi

    case $OS in
        ubuntu)
            print_info "Installing Emacs via apt..."
            sudo add-apt-repository -y ppa:kelleyk/emacs
            sudo apt update
            sudo apt install -y emacs29
            ;;
        fedora)
            print_info "Installing Emacs via dnf..."
            sudo dnf install -y emacs
            ;;
        arch)
            print_info "Installing Emacs via pacman..."
            sudo pacman -S --noconfirm emacs
            ;;
        macos)
            if ! command_exists brew; then
                print_error "Homebrew not found. Installing Homebrew first..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            print_info "Installing Emacs via Homebrew..."
            brew install --cask emacs
            ;;
        *)
            print_error "Unsupported OS. Please install Emacs 29+ manually."
            exit 1
            ;;
    esac

    print_success "Emacs installed successfully"
}

###############################################################################
# System Dependencies
###############################################################################

install_dependencies() {
    print_header "Installing System Dependencies"

    case $OS in
        ubuntu)
            sudo apt install -y \
                git curl wget \
                ripgrep fd-find \
                fonts-firacode fonts-jetbrains-mono \
                libvterm-bin cmake libtool \
                python3-pip nodejs npm
            ;;
        fedora)
            sudo dnf install -y \
                git curl wget \
                ripgrep fd-find \
                fira-code-fonts jetbrains-mono-fonts \
                vterm cmake libtool \
                python3-pip nodejs npm
            ;;
        arch)
            sudo pacman -S --noconfirm \
                git curl wget \
                ripgrep fd \
                ttf-fira-code ttf-jetbrains-mono \
                cmake libtool \
                python-pip nodejs npm
            ;;
        macos)
            brew install \
                git curl wget \
                ripgrep fd \
                cmake libtool \
                python3 node

            # Fonts
            brew tap homebrew/cask-fonts
            brew install --cask font-fira-code font-jetbrains-mono font-iosevka
            ;;
    esac

    print_success "System dependencies installed"
}

###############################################################################
# Ruby Setup
###############################################################################

setup_ruby() {
    print_header "Setting up Ruby Development Tools"

    if ! command_exists ruby; then
        print_warning "Ruby not found. Skipping Ruby setup."
        print_info "Install Ruby manually: https://www.ruby-lang.org/en/documentation/installation/"
        return
    fi

    print_info "Installing Ruby gems..."
    gem install --user-install solargraph rubocop

    print_success "Ruby tools installed"
}

###############################################################################
# Additional Language Servers
###############################################################################

install_language_servers() {
    print_header "Installing Language Servers"

    # TypeScript/JavaScript
    if command_exists npm; then
        print_info "Installing typescript-language-server..."
        npm install -g typescript-language-server typescript
    fi

    # Python
    if command_exists pip3; then
        print_info "Installing python-lsp-server..."
        pip3 install --user 'python-lsp-server[all]'
    fi

    # Go (if installed)
    if command_exists go; then
        print_info "Installing gopls..."
        go install golang.org/x/tools/gopls@latest
    fi

    print_success "Language servers installed"
}

###############################################################################
# Emacs Configuration
###############################################################################

backup_existing_config() {
    if [ -d "$EMACS_DIR" ]; then
        print_warning "Existing Emacs config found at $EMACS_DIR"
        read -p "Backup existing config? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_info "Backing up to $BACKUP_DIR..."
            mv "$EMACS_DIR" "$BACKUP_DIR"
            print_success "Backup created at $BACKUP_DIR"
        else
            print_error "Aborting installation to prevent data loss."
            exit 1
        fi
    fi
}

clone_config() {
    print_header "Cloning Emacs Configuration"

    print_info "Cloning from $REPO_URL..."
    git clone "$REPO_URL" "$EMACS_DIR"

    print_success "Configuration cloned successfully"
}

###############################################################################
# Private Settings Template
###############################################################################

create_private_template() {
    print_header "Creating private.el Template"

    PRIVATE_FILE="$EMACS_DIR/private.el"

    if [ -f "$PRIVATE_FILE" ]; then
        print_warning "private.el already exists. Skipping."
        return
    fi

    cat > "$PRIVATE_FILE" << 'EOF'
;;; private.el --- Private settings (not tracked in git) -*- lexical-binding: t; -*-

;; This file is for personal settings, API keys, and credentials
;; It is loaded by init.el but not tracked in git

;;; Email Configuration (mu4e)
;; (setq user-full-name "Your Name"
;;       user-mail-address "your.email@example.com")

;;; GPTel API Keys
;; OpenAI
;; (setq gptel-api-key "sk-...")

;; Anthropic Claude
;; (setq gptel-backend
;;       (gptel-make-anthropic "Claude"
;;         :stream t
;;         :key "sk-ant-..."))

;;; Other private settings
;; Add your private configuration here

(provide 'private)
;;; private.el ends here
EOF

    print_success "Created private.el template"
    print_info "Edit $PRIVATE_FILE for your personal settings"
}

###############################################################################
# Fonts Installation
###############################################################################

install_nerd_fonts() {
    print_header "Installing Nerd Fonts"

    print_info "Nerd fonts will be installed on first Emacs launch"
    print_info "Run: M-x nerd-icons-install-fonts"
    print_warning "Remember to run this command after first launch!"
}

###############################################################################
# Main Installation Flow
###############################################################################

main() {
    clear
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                               ║${NC}"
    echo -e "${GREEN}║     Little Fox Emacs - Auto Installer        ║${NC}"
    echo -e "${GREEN}║                                               ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════╝${NC}"
    echo ""

    detect_os

    if [ "$OS" == "unknown" ]; then
        print_error "Unsupported operating system"
        exit 1
    fi

    # Confirm installation
    echo ""
    print_info "This script will:"
    echo "  1. Install Emacs 29+ (if needed)"
    echo "  2. Install system dependencies"
    echo "  3. Clone your Emacs configuration"
    echo "  4. Install language servers and tools"
    echo "  5. Set up Ruby development tools"
    echo ""
    read -p "Continue with installation? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_error "Installation cancelled"
        exit 1
    fi

    # Installation steps
    install_emacs
    install_dependencies
    backup_existing_config
    clone_config
    create_private_template
    install_language_servers
    setup_ruby
    install_nerd_fonts

    # Final message
    echo ""
    print_header "Installation Complete! 🎉"
    echo ""
    print_success "Emacs configuration installed successfully"
    echo ""
    print_info "Next steps:"
    echo "  1. Launch Emacs: emacs"
    echo "  2. Wait for packages to install automatically"
    echo "  3. Run: M-x nerd-icons-install-fonts"
    echo "  4. Edit ~/.emacs.d/private.el for personal settings"
    echo ""
    print_info "First launch may take a few minutes to compile packages."
    echo ""

    read -p "Launch Emacs now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        emacs
    fi
}

# Run main function
main
