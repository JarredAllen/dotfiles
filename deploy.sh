#!/bin/bash

HOME_DOTFILES="bash_aliases bashrc tmux.conf vimrc"
HOME_CONFIG_DIRS="git"

HERE=$(dirname "$0")

# cp doesn't work with the -u flag on mac
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

# Set up vim to work as desired
# Set up vundle
if [ -d ~/.vim/bundle/Vundle.vim ]; then
    printf "Updating Vundle: "
    (cd ~/.vim/bundle/Vundle.vim; git pull)
else
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi
# Use Vundle to install plugins
(sleep 20; echo ':q') | vim -S <(cat <<EOF
PluginInstall!
EOF
) 2> /dev/null
