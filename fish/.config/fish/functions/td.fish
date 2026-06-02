function td --description "Add task to ~/todo.md"
    echo "- [ ] $argv" >> ~/todo.md
    echo "Added: $argv"
end
