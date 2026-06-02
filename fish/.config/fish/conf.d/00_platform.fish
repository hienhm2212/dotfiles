# OS detection - used by all other conf.d files
switch (uname -s)
    case linux
	set -gx PLATFORM linux
	set -gx IS_LINUX true
	set -gx IS_MACOS false
    case Darwin
	set -gx PLATFORM macos
	set -gx IS_LINUX false
	set -gx IS_MACOS true
    case '*'
	set -gx PLATFORM unknown
end
