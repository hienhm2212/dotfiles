function groot --description "cd to git repository root"
    set root (git rev-parse --show-toplevel 2>/dev/null)
    if test -n "$root"
        cd $root
    else
        echo "Not inside a git repository"
        return 1
    end
end
