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

# List the network interfaces and ips (TODO looks ugly if interfaces don't all have ip addresses)
ips() {
    ifconfig | awk '{ if ($1 == "inet" || $1 == "inet6"){ print $2 }; if (/^[^ \t]/){printf "%s ",$1} }'
}

# Aliases for docker containers used in classes
alias cs70='docker run -v "$(pwd):/home/student/cs70/" -it harveymudd/cs70-student:fall2019 /bin/zsh'
alias cs70-update='docker pull harveymudd/cs70-student:fall2019'
alias pls='docker run -v "$(pwd):/root/lab" -v "/home/jarred/.vimrc:/root/.vimrc" -v "/home/jarred/.vim:/root/.vim" -it harveymudd/cs131 /bin/zsh'
alias pls-update='docker pull harveymudd/cs131'
alias cs132='docker run -v "$(pwd):/root/lab" -v "/home/jarred/.vimrc:/root/.vimrc" -v "/home/jarred/.vim:/root/.vim" -v "/usr/local/bin/node:/usr/bin/node" -it harveymudd/cs132:2 /bin/zsh'
alias cs132-update='docker pull harveymudd/cs132:2'

# A utility for making and moving to shortcuts in the terminal
sc() {
    if [ "$1" == "-p" ]; then
        echo "Existing shortcuts:"
        for i in ~/.sc_shortcuts/*; do
            echo "$(printf "%12s" "$(basename "$i")"): $(cat "$i")"
        done
        return
    fi
    if [ "$1" == "--check" ]; then
        echo "Dead links:"
        for i in ~/.sc_shortcuts/*; do
            target="$(cat "$i")"
            if [ ! -d "$target" ]; then
                echo "$(printf "%12s" "$i"): $target"
            fi
        done
        return
    fi
    if [ "$1" == "-d" ] || [ "$1" == "--delete" ]; then
        if [ -z "$2" ]; then
            echo 'No shortcut given to remove'
            return
        fi
        rm "$HOME/.sc_shortcuts/$2"
        return
    fi
    if [ -z "$1" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
        if [ -z "$1" ]; then
            echo $'No arguments given'
        fi
        echo $'Argument options:'
        echo $'\tsc [name] [destination]'
        echo $'\t\tCreate a new shortcut'
        echo $'\tsc [name]'
        echo $'\t\tGo to the given shortcut'
        echo $'\tsc -d|--delete [name]'
        echo $'\t\tRemove the specified shortcut'
        echo $'\tsc -p'
        echo $'\t\tList the existing shortcuts'
        echo $'\tsc --check'
        echo $'\t\tList any dead links'
        echo $'\tsc -h|--help'
        echo $'\t\tList this help'
        return
    fi
    if [ -n "$2" ]; then
        if [ ! -d "$2" ]; then
            echo "No such directory: $2"
            return
        fi
        echo "Making $1 point to $2"
        printf "%s" "$2" > ~/.sc_shortcuts/"$1"
        return
    fi
    if [ -n "$1" ]; then
        if [ -f ~/.sc_shortcuts/"$1" ]; then
            echo "Moving to shortcut $1"
            cd "$(cat ~/.sc_shortcuts/"$1")"
            return
        else
            echo "No such shortcut: $1"
            return
        fi
    fi
    echo "This line shouldn't be reached."
    echo "Please report this bug to Jarred Allen <jarredallen73@gmail.com>"
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
    java -cp ".:/usr/share/java/junit-3.8.2.jar" junit.textui.TestRunner "$1"
}
_junit_completion() {
    mapfile -t COMPREPLY< <(ls . | grep "^${COMP_WORDS[COMP_CWORD]}" | grep "[.]class$")
    for ((i=0; i<${#COMPREPLY[@]}; i++)); do
        COMPREPLY[$i]="${COMPREPLY[$i]%.class}"
    done
}
complete -F _junit_completion junit

# Go back to the previous directory (only tested on bash)
alias back="cd ~-/"

# Open a math pset by making it in pdflatex, opening the pdf in evince, then opening the tex file in vim
mpset() {
    if [ -z "$1" ]; then
        echo "No file specified"
        return 1
    fi
    if [ ! -f "$1.tex" ]; then
        echo "Can't find file: \"$1.tex\""
        return 1
    fi
    pdflatex "$1.tex"
    evince "$1.pdf" &> /dev/null &
    PDF_VIEWER_PID=$!
    vim "$1.tex"
    kill "$PDF_VIEWER_PID"
}

# Run clippy with extra denies
alias pclippy='cargo clippy --locked --all-targets --all-features -- -D missing_docs -D unused_extern_crates -D warnings -D clippy::unwrap_used -D clippy::expect_used -D clippy::indexing_slicing -D clippy::panic -D clippy::print_stdout -D clippy::await_holding_lock -D clippy::await_holding_refcell_ref -D clippy::use_self -D clippy::cast_possible_wrap -D clippy::missing_const_for_fn -D clippy::missing_docs_in_private_items -D clippy::mutex_atomic -D clippy::mutex_integer -D clippy::needless_pass_by_value -D clippy::negative_feature_names -D clippy::no_effect_underscore_binding -D clippy::nonstandard_macro_braces -D clippy::path_buf_push_overwrite -D clippy::ptr_as_ptr -D clippy::range_minus_one -D clippy::range_plus_one -D clippy::rc_buffer -D clippy::redundant_closure_for_method_calls -D clippy::redundant_else -D clippy::redundant_feature_names -D clippy::redundant_pub_crate -D clippy::ref_binding_to_reference -D clippy::ref_option_ref -D clippy::rest_pat_in_fully_bound_structs -D clippy::return_self_not_must_use -D clippy::same_functions_in_if_condition -D clippy::suspicious_operation_groupings -D clippy::transmute_ptr_to_ptr -D clippy::undocumented_unsafe_blocks -D clippy::unneeded_field_pattern -D clippy::unnested_or_patterns -D clippy::unreadable_literal -D clippy::useless_let_if_seq -D clippy::verbose_file_reads -D clippy::wildcard_dependencies -D clippy::zero_sized_map_values'
