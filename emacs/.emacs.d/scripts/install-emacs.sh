#!/bin/bash
set -e

# Configuration
EMACS_VERSION="${1:-emacs-30}"  # Default to emacs-30 branch, or pass version as argument
EMACS_SRC="$HOME/src/emacs"
INSTALL_PREFIX="/usr/local"
JOBS=$(nproc)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

install_dependencies() {
    info "Installing build dependencies..."
    sudo apt update
    sudo apt install -y \
        build-essential \
        autoconf \
        texinfo \
        libgtk-3-dev \
        libgnutls28-dev \
        libjpeg-dev \
        libpng-dev \
        libtiff-dev \
        libgif-dev \
        libxpm-dev \
        libncurses-dev \
        libxml2-dev \
        libjansson-dev \
        libsqlite3-dev \
        libwebkit2gtk-4.1-dev \
        libtree-sitter-dev \
        libgccjit-14-dev \
        libmagickwand-dev \
        libacl1-dev \
        libotf-dev \
        libm17n-dev \
        libsystemd-dev \
        mailutils \
        git
}

clone_or_update() {
    if [ -d "$EMACS_SRC" ]; then
        info "Updating Emacs source..."
        cd "$EMACS_SRC"
        git fetch --all
        git checkout "$EMACS_VERSION"
        git pull origin "$EMACS_VERSION" || git pull
    else
        info "Cloning Emacs source..."
        mkdir -p "$(dirname "$EMACS_SRC")"
        git clone --depth 1 --branch "$EMACS_VERSION" https://git.savannah.gnu.org/git/emacs.git "$EMACS_SRC"
        cd "$EMACS_SRC"
    fi
}

build_emacs() {
    info "Building Emacs with native-comp..."
    cd "$EMACS_SRC"

    # Clean previous build
    if [ -f Makefile ]; then
        make clean || true
        make distclean || true
    fi

    # Generate configure script
    ./autogen.sh

    # Configure with native-comp and useful features
    ./configure \
        --prefix="$INSTALL_PREFIX" \
        --with-native-compilation=aot \
        --with-json \
        --with-tree-sitter \
        --with-xwidgets \
        --with-mailutils \
        --with-imagemagick \
        --with-modules \
        --with-sqlite3 \
        --with-xml2 \
        --with-gnutls \
        --with-jpeg \
        --with-png \
        --with-tiff \
        --with-gif \
        --with-xpm \
        --with-rsvg \
        --with-webp \
        --without-pop \
        CFLAGS="-O2 -march=native"

    # Build
    info "Compiling (using $JOBS jobs)..."
    make -j"$JOBS"
}

install_emacs() {
    info "Installing Emacs..."
    cd "$EMACS_SRC"
    sudo make install

    info "Emacs installed successfully!"
    emacs --version
}

show_usage() {
    echo "Usage: $0 [command] [version]"
    echo ""
    echo "Commands:"
    echo "  deps      Install build dependencies only"
    echo "  build     Clone/update and build Emacs"
    echo "  install   Build and install Emacs"
    echo "  all       Do everything (deps + install)"
    echo ""
    echo "Version examples:"
    echo "  emacs-30      Latest Emacs 30 (default)"
    echo "  emacs-29      Emacs 29 branch"
    echo "  master        Latest development"
    echo ""
    echo "Examples:"
    echo "  $0 all                  # Install deps and build emacs-30"
    echo "  $0 install emacs-29    # Build and install emacs-29"
    echo "  $0 build master        # Build latest master branch"
}

# Main
case "${1:-all}" in
    deps)
        install_dependencies
        ;;
    build)
        EMACS_VERSION="${2:-emacs-30}"
        clone_or_update
        build_emacs
        ;;
    install)
        EMACS_VERSION="${2:-emacs-30}"
        clone_or_update
        build_emacs
        install_emacs
        ;;
    all)
        EMACS_VERSION="${2:-emacs-30}"
        install_dependencies
        clone_or_update
        build_emacs
        install_emacs
        ;;
    -h|--help|help)
        show_usage
        ;;
    *)
        # If first arg looks like a version, treat as "all" with version
        if [[ "$1" == emacs-* ]] || [[ "$1" == "master" ]]; then
            EMACS_VERSION="$1"
            install_dependencies
            clone_or_update
            build_emacs
            install_emacs
        else
            error "Unknown command: $1"
        fi
        ;;
esac
