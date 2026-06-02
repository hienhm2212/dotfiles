function extract --description "Extract any archive"
    if not test -f $argv[1]
        echo "Error: '$argv[1]' is not a file"
        return 1
    end
    switch $argv[1]
        case "*.tar.bz2"  ; tar xjf $argv[1]
        case "*.tar.gz"   ; tar xzf $argv[1]
        case "*.tar.xz"   ; tar xJf $argv[1]
        case "*.tar.zst"  ; tar --zstd -xf $argv[1]
        case "*.bz2"      ; bunzip2 $argv[1]
        case "*.gz"       ; gunzip $argv[1]
        case "*.tar"      ; tar xf $argv[1]
        case "*.zip"      ; unzip $argv[1]
        case "*.7z"       ; 7z x $argv[1]
        case "*.rar"      ; unrar x $argv[1]
        case "*"
            echo "Don't know how to extract '$argv[1]'"
            return 1
    end
end
