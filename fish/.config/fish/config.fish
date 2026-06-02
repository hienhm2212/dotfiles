# Entry point - keep lean, logic lives in conf.d/

set -g fish_greeting ""

set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx XDG_DATA_HOME "$HOME/.local/share"
set -gx XDG_CACHE_HOME "$HOME/.cache"
set -gx XDG_STATEE "$HOME/.local/state"

# mise - runtime version manager
if command -q mise
   mise activate fish | source
end