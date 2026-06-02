function search --description "Ctrl+F fuzzy find file in current directory"
    find $PWD 2>/dev/null | fzf -q "'" \
        --preview 'bat --color=always --style=numbers {}' \
        --preview-window 'right:55%' \
        | read -l result
    and commandline -a $result
end
