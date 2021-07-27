# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
# Useful if inputting a command which includes a password, preceed with a space to avoid letting
# the password show up in your history.
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=50000
HISTFILESIZE=100000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

# Use my preferred prompt (with colors if the terminal supports it):
# user@host:dir
# [#] HH:MM$ 
# I like this prompt because command begins at a consistent location regardless of path length and
# short commands are never broken across lines
if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\n[\#] \[\033[01;32m\]\A\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\n[\#]\A\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# Set the default editor to Vim
export EDITOR="vim"

# Use aliases to enable color support for grep and ls, if the terminal supports it
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
else
    if [ "Darwin" = "$(uname -s)" ]; then
        alias ls='ls -G'
    fi
fi

# Use `la` as an alias for `ls -A`, to display hidden folders (excluding . and ..)
alias la='ls -A'

# If doing a long-running command, use `alert` to send a notification when the command finishes
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# Placing aliases in a separate file enables sourcing that separate file to just refresh aliases
# without doing potentially non-idempotent operations here
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Use vim-like keybinds when inputting commands
set -o vi

# Improved tab behavior (if an ambiguous tab is done, cycle between options and show them on screen)
bind 'TAB:menu-complete'
bind 'set show-all-if-ambiguous on'

# Add Ruby Gems to the path if it exists
if [ -d "$HOME/gems" ]; then
    export GEM_HOME="$HOME/gems"
    export PATH="$HOME/gems/bin:$PATH"
fi

# Add yarn to the path if it exists
if [ -d "$HOME/.yarn" ]; then
    export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
fi

# Configure SSH-Agent to have correct environment variables
SSH_ENV="$HOME/.ssh/environment"
function start_agent {
        echo "Initialising new SSH agent..."
        /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
        echo succeeded
        chmod 600 "${SSH_ENV}"
        . "${SSH_ENV}" > /dev/null
        /usr/bin/ssh-add -t 432000 ;
}
if [ -f "${SSH_ENV}" ]; then
        . "${SSH_ENV}" > /dev/null
        ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
                start_agent;
        }
else
        start_agent;
fi

# Source ghcup-env if installed
[ -f "/home/jarred/.ghcup/env" ] && source "/home/jarred/.ghcup/env"

# Add DEVKITPRO environment variables for tonc if it exists
if [ -d "/opt/devkitpro" ]; then
    export DEVKITARM="/opt/devkitpro/devkitARM/"
    export DEVKITPRO="/opt/devkitpro"
    export PATH="$DEVKITARM/bin:$DEVKITPRO/tools/bin:$PATH"
fi

# Add Julia tools to the path if it's installed in /opt/julia
if [ -d "/opt/julia/usr/bin" ]; then
    export PATH="$PATH:/opt/julia/usr/bin"
fi

# Add homebrew to the path, if it exists
if [ -d "/opt/homebrew" ]; then
    export PATH="$PATH:/opt/homebrew/bin:/opt/homebrew/sbin"
    # If we have LLVM installed through homebrew, put it in front
    export PATH="/opt/homebrew/opt/llvm/bin/:$PATH"
fi

# Print a calendar and cowsay a fortune on opening a terminal
fortune | cowsay
cal
