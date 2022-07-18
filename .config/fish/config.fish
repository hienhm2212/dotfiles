set fish_greeting "Greeting! HienHM"

set -gx TERM xterm-256color

# theme
set -g theme_color_scheme terminal-dark
set -g fish_prompt_pwd_dir_length 1
set -g theme_display_user yes
set -g theme_hide_hostname no
set -g theme_hostname always

# aliases
alias ls "ls -p -G"
alias la "ls -A"
alias ll "ll -A"
alias g git

set -gx EDITOR emacs

set -gx PATH bin $PATH
set -gx PATH ~/bin $PATH
set -gx PATH ~/.local/bin $PATH

# NodeJS
set -gx PATH mode_modules/.bin $PATH

# Go
set -g GOPATH $HOME/Projects/go
set -gx PATH $GOPATH/bin $PATH

# NVM

# 
switch (uname)
	case Darwin
		source (dirname (status --current-filename))/config-osx.fish
	case Linux
		source (dirname (status --current-filename))/config-linux.fish
	case '*'
		source (dirname (status --current-filename))/config-windows/fish
end

# Local config
set LOCAL_CONFIG (dirname (status --current-filename))/config-local.fish
if test -f $LOCAL_CONFIG
	source $LOCAL_CONFIG
end
