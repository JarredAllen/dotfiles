#!/bin/bash

# Aliases and shell functions for various useful utilities

# An alias for quickly moving up directories
# Run `..` to move up a directory, or `.. <N>` to move up N directories
..() {
    # shellcheck disable=SC2164
    # we can ignore this issue (`cd` without `|| return`) because cd is the last
    cd "$(for ((c=0; c<${1:-1}; ++c)); do echo -n ../; done)"
}

# A calculator command. Run with an argument to calculate that argument,
# run without to open a fake shell (TODO implement moving the cursor and
# history, idk how yet)
calc() {
    if [ -z "$1" ]; then
        echo -n ">"
        while read -r line; do
            calc "$line"
            echo -n ">"
        done
        echo
    else
        awk "BEGIN{ print $* }";
    fi
}

# Default to python3 in the shell, regardless of system configuration
alias python=python3

# A function for manipulating aliases programmatically
# If two arguments are provided, alias the first argument to the second one. If a third is supplied,
# add that as a comment explaining the alias. Otherwise, open this alias file in vim.
# Either way, reapply the aliases in this file after making changes.
aliases() {
    if [ -n "$2" ]; then
        echo "" >> ~/.bash_aliases
        if [ -n "$3" ]; then
            echo "# $3" >> ~/.bash_aliases
        fi
        echo "alias $1='$2'" >> ~/.bash_aliases
    else
        vim ~/.bash_aliases
    fi
    source ~/.bash_aliases
}
# Reapply the aliases in this file
alias realias="source ~/.bash_aliases"

# Reminders because this happens sometimes
alias :q='echo "You are not in vim, you modron."'
alias :wq='echo "You are not in vim, you modron."'

# Make a new directory and move into that directory
mkcd() {
    # shellcheck disable=SC2164
    # we can ignore this issue (`cd` without `|| return`) because cd is the last
    mkdir -p "$1" && cd "$1";
}

# Make a temporary work directory in `/var/tmp`.
#
# If given, $1 is a base name (will be "/var/tmp/$1.XXXXXX", default 'workdir').
# The remaining arguments are a command to run in the working directory.
temp_workdir() {
    if [ -n "${1:+x}" ]; then
        local -r dirname="$1"
        shift
    else
        local -r dirname="workdir"
    fi
    local -r workdir=$(mktemp --directory "/var/tmp/$dirname.XXXXXX")
    (
        cd "$workdir";
        if [ -n "${1:+x}" ]; then
            "$@" && PROMPT_LABEL="tempdir $dirname" bash -i
        else
            PROMPT_LABEL="tempdir $dirname" bash -i
        fi
    )
    if [ -n "$(findmnt | grep "$workdir")" ]; then
        echo "Not cleaning up $workdir because mount detected"
        return
    fi
    echo "Cleaning up temporary working directory $workdir"
    rm -rf --one-file-system "$workdir"
}

temp_crate() {
    local -r cratename="${1:-test-crate}"
    temp_workdir "$cratename" cargo init --name "$cratename" .
}

temp_unzip() {
    if [ -z "${1:+x}" ] || [ ! -f "$1" ]; then
        echo '$1 must be path to a file to unzip'
        return 1
    fi
    local -r zip_path="$(realpath $1)"
    local -r workdir="${2:-temp-unzip}"
    temp_workdir "$workdir" unzip "$zip_path"
}

temp_untar() {
    if [ -z "${1:+x}" ] || [ ! -f "$1" ]; then
        echo '$1 must be path to a file to unzip'
        return 1
    fi
    local -r tar_path="$(realpath $1)"
    local -r workdir="${2:-temp-untar}"
    temp_workdir "$workdir" tar -xf "$tar_path"
}

temp_repo() {
    if [ -z "${1:+x}" ]; then
        echo '$1 must be a git repo to check out'
        return 1
    fi
    local -r repo_path="$1"
    local -r repo_name="$(basename --suffix=.git $repo_path)"
    shift
    temp_workdir "$repo_name" git clone "$repo_path" . "$@"
}

# List the network interfaces and ips (TODO looks ugly if interfaces don't all have ip addresses)
ips() {
    ifconfig | awk '{ if ($1 == "inet" || $1 == "inet6"){ print $2 }; if (/^[^ \t]/){printf "%s ",$1} }'
}

# Try connecting to an SSH server on loop
sshloop() {
    while true; do ssh $@; sleep 0.5; done
}

# Like cat, but also outputs the filenames
alias cn='tail -vn +1'

# Make filenames lower-case
lcname() {
    if [ -z "$1" ]; then
        echo "Please list the files to make lower case"
    else
        for arg in "$@"; do
            mv "$arg" "$(echo "$arg" | awk '{print tolower($0)}')"
        done
    fi
}

# Run junit more easily (this is the location junit is installed on my laptop, may be different elsewhere)
junit() {
    java -cp ".:/usr/share/java/junit-4.13.2.jar" junit.textui.TestRunner "$1"
}
_junit_completion() {
    mapfile -t COMPREPLY< <(ls . | grep "^${COMP_WORDS[COMP_CWORD]}" | grep "[.]class$")
    for ((i=0; i<${#COMPREPLY[@]}; i++)); do
        COMPREPLY[$i]="${COMPREPLY[$i]%.class}"
    done
}
complete -F _junit_completion junit

# Go to root of the current repository
repo-root() {
    REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
    if [ $? -eq 0 ]; then
        cd "$REPO_ROOT"
    else
        echo "Error: not in a repository"
    fi
}

# Loop a command until it fails, showing the count
test_loop() {
    COUNT=0
    while "$@"; do
        COUNT=$(( COUNT + 1 ))
        echo -e "\n$COUNT successes\n"
    done
    echo -e "\nFailure after $COUNT successes"
}

# Block the system from sleeping for an interval of time
nosleep() {
    if [ -z "$1" ]; then
        systemd-inhibit --who=nosleep --why="Requested no sleep indefinitely" sleep 9999d &>/dev/null
    else
        local -r DURATION="$1"
        systemd-inhibit --who=nosleep --why="Requested no sleep for $DURATION" sleep "$DURATION"
    fi
}

timer() {
    if [ -z "$1" ]; then
        echo "Must specify timer duration"
        return 1
    fi
    local -r DURATION="$1"
    shift
    local -a ARGS
    if [ -z "$1" ]; then
        ARGS=( "$DURATION timer" )
    else
        ARGS=( "$@" )
    fi
    declare -ra ARGS
    sleep "$DURATION"
    notify-send "Timer elapsed!" "${ARGS[*]}"
}
