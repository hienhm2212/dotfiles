function fish_user_key_bindings
    bind \cu 'commandline ""'

    if command -q fzf
        bind \cr fzf-history-widget
        bind \cf search
        bind \ce scd
    else
        bind \cr history-search-backward
    end

    # Alt+Arrow directory navigation
    bind \e\[1\;7D "prevd; echo; commandline -f repaint"
    bind \e\[1\;7C "nextd; echo; commandline -f repaint"
    bind \e\[1\;7A "cd ..; echo; commandline -f repaint"

    bind ! bind_bang
    bind '$' bind_dollar
end
