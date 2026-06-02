function scd --description "Ctrl+E frecency directory jump"
    cat ~/.local/share/fish/fish_dir_history 2>/dev/null | sort | uniq -c | sort -rn | \
        fzf -q "'" -e +m --tiebreak=index --sort \
        | string replace -r '^\s*\d+\s+' '' \
        | read -l result
    and cd $result
    and commandline -f repaint
    and ls
end
