function bak --description "Backup a file with .bak extension"
    cp -i "$argv" "$argv.bak"
end
