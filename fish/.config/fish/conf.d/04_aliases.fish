# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias -- cdback="cd -"

# Listing
if command -q eza
    alias ls="eza --group-directories-first --icons"
    alias ll="eza -la --group-directories-first --icons --git"
    alias lt="eza --tree --level=2 --icons"
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
alias free="free -m"
alias sizeof="du -hs"
alias fs="df -h -x squashfs -x tmpfs -x devtmpfs"

# Network
alias myip="curl ifconfig.co"
alias localip="ip -o route get to 1.1.1.1 | sed -n 's/.*src \([0-9.]\+\).*\1/p'"
alias whereami="curl ifconfig.co/json"
alias ports="ss -tulnp"

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

# Misc
alias reload="exec fish"
alias dotfiles="cd $HOME/.dotfiles"
alias b="bash -c"

# Platform specific
if test "$PLATFORM" = linux
    alias open="xdg-open"
    alias pbcopy="xclip -selection clipboard"
    alias pbpaste="xclip -selection clipboard -o"
    alias update="sudo apt update && sudo apt upgrade -y"
else if test "$PLATFORM" = macos
    alias update="brew update && brew upgrade"
end
