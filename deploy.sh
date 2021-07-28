#!/bin/bash

# The dotfiles directly in my home to copy out
HOME_DOTFILES="bash_aliases bashrc tmux.conf vimrc"
# Directories in my home's .config directory
HOME_CONFIG_DIRS="git"

Usage() {
    echo 'Usage:'
    echo './deploy.sh [home]'
    echo
    echo 'Arguments:'
    echo '[home]: The directory to deploy files to [default: your home directory]'
}

TARGET=
while (( "$#" )); do
    case "$1" in
        -h|--help) # Help message
            Usage
            exit 0
        ;;
        -*|--*) # Unsupported flags
            1>&2 echo "Error: Unsupported flag: $1"
            exit 1
        ;;
        *) # One positional argument for home, more are invalid
            if [ "$TARGET" = "" ]; then
                TARGET="$1"
            else
                1>&2 echo 'Error: Too many positional args'
                exit 1
            fi
        ;;
    esac
done

# Make $HERE refer to the directory of this script, so it will still work if run from another directory
HERE=$(dirname "$0")

# cp doesn't work with the -u flag on mac (-u doesn't copy if destination file is newer than here)
CP_ARGS="-vu"
if [ "Darwin" = "$(uname -s)" ]; then
    CP_ARGS="-v"
fi

# Allow the target directory to be changed from default if desired
# (defaults to user's home directory)
if [ -z "$TARGET" ]; then
    TARGET="$HOME"
fi
echo "Deploying to $TARGET..."
# Copy dotfiles from here to the home directory
for file in $HOME_DOTFILES; do
    cp $CP_ARGS "$HERE/$file" "$TARGET/.$file"
done
# Copy .config subdirs recursively to the home directory
for dir in $HOME_CONFIG_DIRS; do
    cp $CP_ARGS -R "$HERE/$dir" "$TARGET/.config/"
done
# Set some global git configuration variables
# TODO Figure out how to arrange these variables in a more easily readable/editable manner
GIT_CONFIG=$'pull.ff only\nuser.name "Jarred Allen"\ncore.excludesfile ~/.config/git/ignore'
bash <(while IFS=$'\n' read -r option; do echo "git config --file \"$TARGET/.gitconfig\" --replace-all $option"; done <<< "$GIT_CONFIG")

# Set up vim to work as desired
# Set up vundle
if [ -d ~/.vim/bundle/Vundle.vim ]; then
    printf "Updating Vundle: "
    (cd ~/.vim/bundle/Vundle.vim; git pull)
else
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi
# Use Vundle to install plugins
# TODO figure out how to wait until it finishes, instead of having a fixed 20-second timer
(sleep 20; echo ':q') | vim -S <(cat <<EOF
PluginInstall!
EOF
) 2> /dev/null
