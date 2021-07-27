#!/bin/bash

# The dotfiles directly in my home to copy out
HOME_DOTFILES="bash_aliases bashrc tmux.conf vimrc"
# Directories in my home's .config directory
HOME_CONFIG_DIRS="git"

# Make $HERE refer to the directory of this script, so it will still work if run from another directory
HERE=$(dirname "$0")

# cp doesn't work with the -u flag on mac (-u doesn't copy if destination file is newer than here)
CP_ARGS="-vu"
if [ "Darwin" = "$(uname -s)" ]; then
    CP_ARGS="-v"
fi

# Allow the target directory to be changed from default if desired
# (defaults to user's home directory)
if [ -n "$1" ]; then
    HOME="$1"
fi
echo "Deploying to $HOME..."
# Copy dotfiles from here to the home directory
for file in $HOME_DOTFILES; do
    cp $CP_ARGS "$HERE/$file" "$HOME/.$file"
done
# Copy .config subdirs recursively to the home directory
for dir in $HOME_CONFIG_DIRS; do
    cp $CP_ARGS -R "$HERE/$dir" "$HOME/.config/"
done
# Set some global git configuration variables
# TODO Figure out how to arrange these variables in a more easily readable/editable manner
GIT_CONFIG=$'pull.ff only\nuser.name "Jarred Allen"\ncore.excludesfile ~/.config/git/ignore'
bash <(while IFS=$'\n' read -r option; do echo "git config --file \"$HOME/.gitconfig\" --replace-all $option"; done <<< "$GIT_CONFIG")

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
