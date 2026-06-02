function copy --description "Copy pipe or argument to clipboard"
    if [ "$argv" = "" ]
        xclip -sel clip
    else
        printf "%s" "$argv" | xclip -sel clip
    end
end
