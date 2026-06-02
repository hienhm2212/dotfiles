if command -q starship
    set -gx STARSHIP_CONFIG "$HOME/.config/starship.toml"
    starship init fish | source
end
