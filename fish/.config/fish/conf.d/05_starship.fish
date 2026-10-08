# Prompt: starship, unless tide (installed via fisher) is present on this machine
if command -q starship; and not functions -q tide
    set -gx STARSHIP_CONFIG "$HOME/.config/starship.toml"
    starship init fish | source
end
