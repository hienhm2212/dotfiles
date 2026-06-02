function save_dir --on-event fish_postexec --description "Save visited dirs for scd"
    test "$last_pwd" != "$PWD"
    and echo "$PWD" >> ~/.local/share/fish/fish_dir_history
    set -g last_pwd "$PWD"
end
