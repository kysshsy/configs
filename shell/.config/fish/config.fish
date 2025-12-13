#
# Personal fish config, grouped by type:
# - Abbreviations
# - Locale / shell settings
# - Environment / PATH / tools
# - Functions and key bindings
# - Aliases and Arch helpers
# - Dev toolchains and proxies
#

## Abbreviations (general tooling)
abbr -a yr 'cal -y'
abbr -a e nvim
abbr -a m make
abbr -a o xdg-open
abbr -a g git
abbr -a gc 'git checkout'
abbr -a ga 'git add -p'
abbr -a glp 'git log --pretty="%C(Yellow)%h  %C(reset)%ad (%C(Green)%cr%C(reset))%x09 %C(Cyan)%an: %C(reset)%s"'
abbr -a vimdiff 'nvim -d'
abbr -a amz 'env AWS_SECRET_ACCESS_KEY=(pass www/aws-secret-key | head -n1)'
abbr -a ais "aws ec2 describe-instances | jq '.Reservations[] | .Instances[] | {iid: .InstanceId, type: .InstanceType, key:.KeyName, state:.State.Name, host:.PublicDnsName}'"
abbr -a gha 'git stash; and git pull --rebase; and git stash pop'
abbr -a ks 'keybase chat send'
abbr -a kr 'keybase chat read'
abbr -a kl 'keybase chat list'
abbr -a pr 'gh pr create -t (git show -s --format=%s HEAD) -b (git show -s --format=%B HEAD | tail -n+3)'
abbr -a ze zellij
abbr cat 'bat --style header,snip,changes'


## Package manager helpers (Arch / AUR)
if command -v paru > /dev/null
        abbr -a p 'paru'
        abbr -a up 'paru -Syu'
else if command -v aurman > /dev/null
        abbr -a p 'aurman'
        abbr -a up 'aurman -Syu'
else
        abbr -a p 'sudo pacman'
        abbr -a up 'sudo pacman -Syu'
end

complete --command aurman --wraps pacman


## Locale and core shell settings
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Hide welcome message & ensure we are reporting fish as shell
set fish_greeting
set VIRTUAL_ENV_DISABLE_PROMPT "1"
set -xU MANPAGER "sh -c 'col -bx | bat -l man -p'"
set -xU MANROFFOPT "-c"
set -x EDITOR nvim


## Desktop / theme / notification settings
# Qt theme when running inside qtile
if type "qtile" >> /dev/null 2>&1
   set -x QT_QPA_PLATFORMTHEME "qt5ct"
end

# Settings for https://github.com/franciscolourenco/done
set -U __done_min_cmd_duration 10000
set -U __done_notification_urgency_level low


## Environment setup (extra config)
# Apply .profile: use this to put fish compatible .profile stuff in
if test -f ~/.fish_profile
  source ~/.fish_profile
end

# Load per-user secrets (API keys, tokens, etc.), if present.
# This file is git-ignored via ~/.config/.gitignore.
if test -f ~/.config/fish/secrets.fish
  source ~/.config/fish/secrets.fish
end


## PATH tweaks and prompt / command-not-found
# Add ~/.local/bin to PATH
if test -d ~/.local/bin
    if not contains -- ~/.local/bin $PATH
        set -p PATH ~/.local/bin
    end
end

## Starship prompt
if status --is-interactive; and type -q starship
    starship init fish --print-full-init | source
end

## Advanced command-not-found hook (optional)
if test -f /usr/share/doc/find-the-command/ftc.fish
    source /usr/share/doc/find-the-command/ftc.fish
end


## History helpers and key bindings
# Functions needed for !! and !$ https://github.com/oh-my-fish/plugin-bang-bang
function __history_previous_command
  switch (commandline -t)
  case "!"
    commandline -t $history[1]; commandline -f repaint
  case "*"
    commandline -i !
  end
end

function __history_previous_command_arguments
  switch (commandline -t)
  case "!"
    commandline -t ""
    commandline -f history-token-search-backward
  case "*"
    commandline -i '$'
  end
end

if [ "$fish_key_bindings" = fish_vi_key_bindings ];
  bind -Minsert ! __history_previous_command
  bind -Minsert '$' __history_previous_command_arguments
else
  bind ! __history_previous_command
  bind '$' __history_previous_command_arguments
end

# Fish command history
function history
    builtin history --show-time='%F %T '
end


## Small helper functions
function backup --argument filename
    cp $filename $filename.bak
end

# Copy DIR1 DIR2
function copy
    set count (count $argv | tr -d \n)
    if test "$count" = 2; and test -d "$argv[1]"
        set from (echo $argv[1] | string trim --right --chars=/)
        set to (echo $argv[2])
        command cp -r $from $to
    else
        command cp $argv
    end
end

# Cleanup local orphaned packages
function cleanup
    while pacman -Qdtq
        sudo pacman -R (pacman -Qdtq)
    end
end


## Useful aliases
# Replace ls with eza
alias ls 'eza -al --color=always --group-directories-first ' # preferred listing
alias la 'eza -a --color=always --group-directories-first '  # all files and dirs
alias ll 'eza -l --color=always --group-directories-first '  # long format
alias lt 'eza -aT --color=always --group-directories-first ' # tree listing
alias l. 'eza -ald --color=always --group-directories-first .*' # show only dotfiles

# Replace some more things with better alternatives
if not test -x /usr/bin/yay; and test -x /usr/bin/paru
    alias yay 'paru'
end

alias j z

# Common use
alias .. 'cd ..'
alias ... 'cd ../..'
alias .... 'cd ../../..'
alias ..... 'cd ../../../..'
alias ...... 'cd ../../../../..'
alias big 'expac -H M "%m\t%n" | sort -h | nl'     # Sort installed packages according to size in MB (expac must be installed)
alias dir 'dir --color=auto'
alias fixpacman 'sudo rm /var/lib/pacman/db.lck'
alias gitpkg 'pacman -Q | grep -i "\-git" | wc -l' # List amount of -git packages
## grep family: prefer ugrep if available, otherwise fall back to grep
if type -q ugrep
    alias grep 'ugrep --color=auto'
    alias egrep 'ugrep -E --color=auto'
    alias fgrep 'ugrep -F --color=auto'
else
    alias grep 'grep --color=auto'
    alias egrep 'grep -E --color=auto'
    alias fgrep 'grep -F --color=auto'
end
alias grubup 'sudo update-grub'
alias hw 'hwinfo --short'                          # Hardware Info
alias ip 'ip -color'
alias psmem 'ps auxf | sort -nr -k 4'
alias psmem10 'ps auxf | sort -nr -k 4 | head -10'
alias rmpkg 'sudo pacman -Rdd'
alias tarnow 'tar -acf '
alias untar 'tar -zxvf '
alias upd '/usr/bin/garuda-update'
alias vdir 'vdir --color=auto'
alias vim 'nvim'
alias wget 'wget -c '

# Get fastest mirrors
alias mirror 'sudo reflector -f 30 -l 30 --number 10 --verbose --save /etc/pacman.d/mirrorlist'
alias mirrora 'sudo reflector --latest 50 --number 20 --sort age --save /etc/pacman.d/mirrorlist'
alias mirrord 'sudo reflector --latest 50 --number 20 --sort delay --save /etc/pacman.d/mirrorlist'
alias mirrors 'sudo reflector --latest 50 --number 20 --sort score --save /etc/pacman.d/mirrorlist'

# Help people new to Arch
alias apt 'man pacman'
alias apt-get 'man pacman'
alias please 'sudo'
alias tb 'nc termbin.com 9999'
alias helpme 'echo "To print basic information about a command use tldr <command>"'
alias pacdiff 'sudo -H DIFFPROG=meld pacdiff'

# Get the error messages from journalctl
alias jctl 'journalctl -p 3 -xb'

# Recent installed packages
alias rip 'expac --timefmt="%Y-%m-%d %T" "%l\t%n %v" | sort | tail -200 | nl'


## CLI eye-candy and navigation tools
# Run fastfetch if session is interactive
if status --is-interactive && type -q fastfetch
   fastfetch --config neofetch.jsonc
end

# Initialize zoxide
if command -v zoxide >/dev/null
    zoxide init fish | source
end


## Conda / Python
set -x PATH /home/kyss/miniconda3/bin $PATH

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if test -f /home/kyss/miniconda3/bin/conda
    eval /home/kyss/miniconda3/bin/conda "shell.fish" "hook" $argv | source
else
    if test -f "/home/kyss/miniconda3/etc/fish/conf.d/conda.fish"
        . "/home/kyss/miniconda3/etc/fish/conf.d/conda.fish"
    else
        set -x PATH "/home/kyss/miniconda3/bin" $PATH
        bind "Tab" { ToggleTab; }
    end
end
# <<< conda initialize <<<


## Fuzzy finder key bindings
if type -q fzf
    fzf --fish | source
end


## Haskell toolchain (ghcup / cabal)
set -q GHCUP_INSTALL_BASE_PREFIX[1]; or set GHCUP_INSTALL_BASE_PREFIX $HOME ; set -gx PATH $HOME/.cabal/bin /home/kyss/.ghcup/bin $PATH # ghcup-env


## Proxy
# proxy
export http_proxy=http://127.0.0.1:7890
export https_proxy=$http_proxy
