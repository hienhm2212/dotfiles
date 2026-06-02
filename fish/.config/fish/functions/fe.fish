function fe --description "Fuzzy find file and open in \$EDITOR"
    set file (fzf --preview "bat --color=always --style=numbers {}" \
        --preview-window=right:60%)
    if test -n "$file"
        eval $EDITOR $file
    end
end
