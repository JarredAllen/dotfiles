..() {
    cd $(for ((c=0; c<${1:-1}; ++c)); do echo -n ../; done)
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

alias python=python3

# A function for manipulating aliases programmatically
# If two arguments are provided, alias the first argument to the second one. If a third is supplied,
# add that as a comment explaining the alias. Otherwise, open this alias file in vim.
# Either way, apply the aliases in this file after making changes.
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
    realias
}
alias realias="source ~/.bash_aliases"

alias :q='echo "You are not in vim, you modron."'
alias :wq='echo "You are not in vim, you modron."'

mkcd() { mkdir -p "$1" && cd "$1"; }

ips() {
    ifconfig | awk '{ if ($1 == "inet"){ print $2 }; if (/^[^ \t]/){printf "%s ",$1} }'
}

alias cs70='docker run -v "$(pwd):/home/student/cs70/" -it harveymudd/cs70-student:fall2019 /bin/zsh'
alias cs70-update='docker pull harveymudd/cs70-student:fall2019'

alias pls='docker run -v "$(pwd):/root/lab" -v "/home/jarred/.vimrc:/root/.vimrc" -v "/home/jarred/.vim:/root/.vim" -it harveymudd/cs131 /bin/zsh'
alias pls-update='docker pull harveymudd/cs131'

# A utility for making and moving to shortcuts in the terminal
sc() {
    if [ "$1" == "-p" ]; then
        echo "Existing shortcuts:"
        for i in $(ls ~/.sc_shortcuts); do
            echo "$(printf "%12s" "$i"): $(cat ~/.sc_shortcuts/"$i")"
        done
        return
    fi
    if [ -z "$1" -o "$1" == "-h" -o "$1" == "--help" ]; then
        if [ -z "$1" ]; then
            echo $'No arguments given'
        fi
        echo $'Argument options:'
        echo $'\tsc [name] [destination]'
        echo $'\t\tCreate a new shortcut'
        echo $'\tsc [name]'
        echo $'\t\tGo to the given shortcut'
        echo $'\tsc -p'
        echo $'\t\tList the existing shortcuts'
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
        printf "%s" $2 > ~/.sc_shortcuts/"$1"
        return
    fi
    if [ -n "$1" ]; then
        if [ -f ~/.sc_shortcuts/"$1" ]; then
            echo "Moving to shortcut $1"
            cd $(cat ~/.sc_shortcuts/"$1")
        else
            echo "No such shortcut: $1"
        fi
        return
    fi
    echo "This line shouldn't be reached."
    echo "Please report this bug to Jarred Allen <jarredallen73@gmail.com>"
}

# Output files and filenames
alias cn='tail -vn +1'

# Make filenames lower-case
lcname() {
    if [ -z "$1" ]; then
        echo "Please list the files to make lower case"
    else
        for arg in "$@"; do
            mv "$arg" $(echo "$arg" | awk '{print tolower($0)}')
        done
    fi
}

# Run junit more easily
junit() {
    java -cp ".:/usr/share/java/junit-3.8.2.jar" junit.textui.TestRunner "$1"
}
_junit_completion() {
    dirname=$(dirname "${COMP_WORDS[COMP_CWORD]}")
    basename=$(basename "${COMP_WORDS[COMP_CWORD]}")
    mapfile -t COMPREPLY< <(ls . | grep "^${COMP_WORDS[COMP_CWORD]}" | grep "[.]class$")
    for ((i=0; i<${#COMPREPLY[@]}; i++)); do
        COMPREPLY[$i]="${COMPREPLY[$i]%.class}"
    done
}
complete -F _junit_completion junit

# Go back
alias back="cd ~-/"
