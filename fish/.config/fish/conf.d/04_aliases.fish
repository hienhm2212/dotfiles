# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias -- cdback="cd -"

# Listing
if command -q eza
    alias ls="eza --group-directories-first --icons"
    alias ll="eza -la --group-directories-first --icons --git"
    alias lt="eza --tree --level=2 --icons"
else if test "$PLATFORM" = macos
    alias ls="ls -G"
    alias ll="ls -lahFG"
else
    alias ls="ls --color=auto"
    alias ll="ls -lahF --color=auto"
end

# System
alias mkdir="mkdir -pv"
alias cp="cp -i"
alias mv="mv -i"
alias df="df -h"
alias du="du -ch"
alias sizeof="du -hs"

# Network
alias myip="curl ifconfig.co"
alias whereami="curl ifconfig.co/json"

# Emacs
alias e="emacsclient -t -a emacs"
alias ec="emacsclient -c -a emacs"
alias ek="emacsclient -e '(kill-emacs)'"

# Git abbrs - visibal expansion is the point
abbr -a g    git
abbr -a gs   'git status -sb'
abbr -a ga   'git add'
abbr -a gaa  'git add --all'
abbr -a gc   'git commit -v'
abbr -a gcm  'git commit -m'
abbr -a gca  'git commit -v --amend'
abbr -a gp   'git push'
abbr -a gp!  'git push --force-with-lease'
abbr -a gpl  'git pull --rebase'
abbr -a gf   'git fetch --all --prune'
abbr -a gco  'git checkout'
abbr -a gsw  'git switch'
abbr -a gswc 'git switch --create'
abbr -a gd   'git diff'
abbr -a gds  'git diff --staged'
abbr -a gl   'git log --oneline --graph --decorate -20'
abbr -a grb  'git rebase'
abbr -a grbi 'git rebase --interactive'
abbr -a grbc 'git rebase --continue'
abbr -a grba 'git rebase --abort'
abbr -a grh  'git reset'
abbr -a grhh 'git reset --hard'
abbr -a gst  'git stash'
abbr -a gstp 'git stash pop'

# tmux - attach to "main" or create it
abbr -a ta 'tmux new-session -A -s main'
abbr -a tl 'tmux list-sessions'

# Misc
alias reload="exec fish"
alias dotfiles="cd $HOME/.dotfiles"
alias b="bash -c"

# Platform specific - free/fs/localip/ports wrap GNU/iproute2 tools on Linux
# and their BSD/macOS equivalents on macOS
if test "$PLATFORM" = linux
    alias free="free -m"
    alias fs="df -h -x squashfs -x tmpfs -x devtmpfs"
    alias localip="ip -o route get to 1.1.1.1 | sed -n 's/.*src \([0-9.]\+\).*/\1/p'"
    alias ports="ss -tulnp"
    alias open="xdg-open"
    alias pbcopy="xclip -selection clipboard"
    alias pbpaste="xclip -selection clipboard -o"
    alias update="sudo apt update && sudo apt upgrade -y"
else if test "$PLATFORM" = macos
    alias free="top -l 1 -s 0 | grep PhysMem"
    alias fs="df -hl"
    alias localip="ipconfig getifaddr (route -n get default | awk '/interface:/ {print \$2}')"
    alias ports="lsof -nP -iTCP -sTCP:LISTEN"
    alias update="brew update && brew upgrade"
end
