function ide --description "Split the tmux window into an editor + 3 terminals layout"
    if not set -q TMUX
        echo "ide: run inside tmux" >&2
        return 1
    end
    # Takuya's layout: a narrow column on the right, three panes along the
    # bottom (e.g. rails server / console / logs), the editor top-left
    tmux split-window -h -l 20% -c $PWD
    tmux select-pane -L
    tmux split-window -v -l 30% -c $PWD
    tmux split-window -h -l 66% -c $PWD
    tmux split-window -h -l 50% -c $PWD
    tmux select-pane -t '{top-left}'
end
