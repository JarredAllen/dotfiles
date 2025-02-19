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
    (cd "$workdir"; if [ -n "${2:+x}" ]; then "$@" ; fi ; bash)
    if [ -n "$(findmnt | grep "$workdir")" ]; then
        echo "Not cleaning up $workdir because mount detected"
        return
    fi
    echo "Cleaning up temporary working directory $workdir"
    rm -rf "$workdir"
}

temp_crate() {
    local -r cratename="${1:-test-crate}"
    temp_workdir "$cratename" cargo init --name "$cratename" .
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

# Run clippy with extra denies
pclippy() {
    cargo clippy --all-targets --all-features $1 -- \
        -D missing_docs -D unused_extern_crates -D warnings -D clippy::complexity -D clippy::correctness -D clippy::pedantic -D clippy::perf -D clippy::style -D clippy::suspicious \
        -D clippy::expect_used -D clippy::indexing_slicing -D clippy::missing_docs_in_private_items -D clippy::panic -D clippy::print_stdout -D clippy::rc_buffer \
        -D clippy::rest_pat_in_fully_bound_structs -D clippy::undocumented_unsafe_blocks -D clippy::unneeded_field_pattern -D clippy::unwrap_used -D clippy::verbose_file_reads \
        -D clippy::negative_feature_names -D clippy::redundant_feature_names -D clippy::wildcard_dependencies -D clippy::iter_with_drain -D clippy::missing_const_for_fn -D clippy::mutex_atomic \
        -D clippy::mutex_integer -D clippy::nonstandard_macro_braces -D clippy::path_buf_push_overwrite -D clippy::redundant_pub_crate -D clippy::suspicious_operation_groupings -D clippy::use_self \
        -D clippy::useless_let_if_seq -D clippy::allow_attributes_without_reason -A clippy::cast_possible_truncation -A clippy::cast_precision_loss -A clippy::cast_sign_loss -A clippy::if_not_else \
        -A clippy::inconsistent_struct_constructor -A clippy::items_after_statements -A clippy::similar_names -A clippy::float_cmp -A clippy::fn_params_excessive_bools -A clippy::missing_errors_doc \
        -A clippy::missing_panics_doc -A clippy::module_name_repetitions -A clippy::struct_excessive_bools -A clippy::too_many_lines -A clippy::result_large_err -A clippy::match_bool \
        -A clippy::struct_field_names -A async_fn_in_trait $2
}
pfclippy() {
    cargo clippy --target thumbv7em-none-eabihf --all-features $1 -- \
        -D missing_docs -D unused_extern_crates -D warnings -D clippy::complexity -D clippy::correctness -D clippy::pedantic -D clippy::perf -D clippy::style -D clippy::suspicious \
        -D clippy::expect_used -D clippy::indexing_slicing -D clippy::missing_docs_in_private_items -D clippy::panic -D clippy::print_stdout -D clippy::rc_buffer \
        -D clippy::rest_pat_in_fully_bound_structs -D clippy::undocumented_unsafe_blocks -D clippy::unneeded_field_pattern -D clippy::unwrap_used -D clippy::verbose_file_reads \
        -D clippy::negative_feature_names -D clippy::redundant_feature_names -D clippy::wildcard_dependencies -D clippy::iter_with_drain -D clippy::missing_const_for_fn -D clippy::mutex_atomic \
        -D clippy::mutex_integer -D clippy::nonstandard_macro_braces -D clippy::path_buf_push_overwrite -D clippy::redundant_pub_crate -D clippy::suspicious_operation_groupings \
        -D clippy::use_self -D clippy::useless_let_if_seq -D clippy::allow_attributes_without_reason -A clippy::cast_possible_truncation -A clippy::cast_precision_loss -A clippy::cast_sign_loss \
        -A clippy::if_not_else -A clippy::inconsistent_struct_constructor -A clippy::items_after_statements -A clippy::similar_names -A clippy::float_cmp -A clippy::fn_params_excessive_bools \
        -A clippy::missing_errors_doc -A clippy::missing_panics_doc -A clippy::module_name_repetitions -A clippy::struct_excessive_bools -A clippy::too_many_lines -A clippy::result_large_err \
        -A clippy::match_bool -A clippy::struct_field_names -A async_fn_in_trait $2
}
