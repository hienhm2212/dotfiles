function launch --description "Launch GUI app detached from terminal"
    eval "$argv >/dev/null 2>&1 &" & disown
end
