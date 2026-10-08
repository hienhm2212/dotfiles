function _clip --description "Copy stdin to the system clipboard"
    if command -q pbcopy
        pbcopy
    else if set -q WAYLAND_DISPLAY; and command -q wl-copy
        wl-copy
    else
        xclip -selection clipboard
    end
end
