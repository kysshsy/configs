## Color theme and syntax highlighting for fish
## This file is auto‑loaded for every interactive fish session.

if not status --is-interactive
    exit
end

# Autosuggestions (ghost text)
set -U fish_color_autosuggestion brblack

# Ctrl‑C / cancelled command marker
set -U fish_color_cancel -r

# Valid command names (builtins, functions, executables)
# Use green instead of the terminal default "normal"/white.
set -U fish_color_command green

# Comments starting with '#'
set -U fish_color_comment red

# Current working directory in the prompt (normal user / root)
set -U fish_color_cwd green
set -U fish_color_cwd_root red

# Command separators like ';' and '&'
set -U fish_color_end green

# Errors and invalid commands
set -U fish_color_error brred

# Escape sequences like \n, \x70, etc.
set -U fish_color_escape brcyan

# History / directory history current entry
set -U fish_color_history_current --bold

# Hostname in prompt (local vs remote)
set -U fish_color_host normal
set -U fish_color_host_remote yellow

# Default / reset color
set -U fish_color_normal normal

# Operators such as globbing tokens
set -U fish_color_operator brcyan

# Command parameters / arguments
set -U fish_color_param cyan

# Quoted strings
set -U fish_color_quote yellow

# Redirections like '>', '2>', etc.
set -U fish_color_redirection cyan --bold

# Search matches (history search, pager selection)
set -U fish_color_search_match white --background=brblack --bold

# Selected text (vi visual mode, etc.)
set -U fish_color_selection white --background=brblack --bold

# Last command non‑zero exit status in prompt
set -U fish_color_status red

# Username in prompt
set -U fish_color_user brgreen

# Valid paths get underlined
set -U fish_color_valid_path --underline

