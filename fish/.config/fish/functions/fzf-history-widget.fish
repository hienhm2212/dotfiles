function fzf-history-widget --description "Ctrl+R fuzzy history search"
    history merge
    history | fzf -q (commandline) -e +m --tiebreak=index --sort \
        --preview-window 'up:50%:wrap:hidden' \
        --preview 'echo {}' \
        --bind "left:execute(printf ' commandline %q' {})+cancel+cancel" \
        --bind "right:execute(printf ' commandline %q' {})+cancel+cancel" \
        --bind "del:execute(printf ' history delete %q' {})+cancel+cancel" \
        --bind "ctrl-x:execute(echo {} | xclip -sel clip)+cancel+cancel" \
        --bind "ctrl-a:toggle-preview" \
        --header "[⏎] run  [←] edit  [del] delete  [ctrl+x] copy" \
        | read -l -d \0 result
    and commandline $result
    and commandline -f repaint
    and commandline -f execute
end
