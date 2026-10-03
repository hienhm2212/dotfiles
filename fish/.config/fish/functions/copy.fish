function copy --description "Copy pipe or argument to clipboard"
    if [ "$argv" = "" ]
        _clip
    else
        printf "%s" "$argv" | _clip
    end
end
