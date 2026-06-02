# fzf

if command -q fzf
    set -gx FZF_DEFAULT_COMMAND "fd --type -f --hidden --follow --exclude .git"
    set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
    set -gx FZF_ALT_C_COMMAND "fd --type d --hidden --follow --exclude .git"
    set -gx FZF_DEFAULT_OPTS "\
        --height 40% \
        --layout=reverse \
        --border=rounded \
        --bind='ctrl-/:toggle-preview' \
        --color=fg:#cdd6f4,bg:#1e1e2e,hl:#89b4fa \
        --color=fg+:#cdd6f4,bg+:#313244,hl+:#89b4fa \
        --color=info:#cba6f7,prompt:#89b4fa,pointer:#f38ba8 \
        --color=marker:#a6e3a1,spinner:#f5c2e7,header:#94e2d5"
end

# bat
if command -q bat
    set -gx BAT_THEME "Catppuccin Mocha"
    alias cat="bat --style=plain"
end

# zoxide
if command -q zoxide
    zoxide init fish | source
end

# ripgrep
if command -q rg
    set -gx RIPGREP_CONFIG_PATH "$HOME/.config/ripgrep/config"
end
