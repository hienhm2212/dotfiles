# Environment variables and PATH

set -gx EDITOR "emacsclient -t -a emacs"
set -gx VISUAL "emacsclient -t -a emacs"

# System package paths first, so the user paths below take precedence
if test "$PLATFORM" = linux
    fish_add_path "/usr/local/bin"
else if test "$PLATFORM" = macos
    # Apple Silicon installs to /opt/homebrew, Intel to /usr/local
    for brew in /opt/homebrew/bin/brew /usr/local/bin/brew
        if test -x $brew
            $brew shellenv fish | source
            break
        end
    end
end

fish_add_path "$HOME/.local/bin"
fish_add_path "$HOME/bin"

set -gx PAGER less
set -gx LESS "-R --quit-if-one-screen --no-init"
set -gx LANG en_US.UTF-8
set -gx LC_ALL en_US.UTF-8
set -gx PKG_CONFIG_PATH "/usr/local/lib/pkgconfig" $PKG_CONFIG_PATH
