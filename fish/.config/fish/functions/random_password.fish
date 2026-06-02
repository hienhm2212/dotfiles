function random-password --description "Generate random password"
    set length $argv[1]
    test -n "$length"; or set length 16
    head /dev/urandom | tr -dc "[:alnum:]~!#\$%^&*-+=?./|" | head -c $length
    echo
end
