# Environment variables and PATH

set -gx EDITOR "emacsclient -t -a emacs"
set -gx VISUAL "emacsclient -t -a emacs"

fish_add_path "$HOME/.local/bin"
fish_add_path "$HOME/bin"

if test "$PLATFORM" = linux
    fish_add_path "/usr/local/bin"
else if test "$PLATFORM" = macos
    fish_add_path "/opt/homebrew/bin"
    fish_add_path "/opt/homebrew/sbin"
end

set -gx PAGER less
set -gx LESS "-R --quit-if-one-screen --no-init"
set -gx LANG en_US.UTF-8
set -gx LC_ALL en_US.UTF-8
