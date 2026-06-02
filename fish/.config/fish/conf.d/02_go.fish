# Go toolchain
if command -q go
    set -gx GOPATH "$HOME/go"
    set -gx GOBIN "$GOPATH/bin"
    fish_add_path "$GOBIN"
end
