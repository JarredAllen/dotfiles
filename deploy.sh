#!/bin/bash

HOME_DOTFILES="bash_aliases bashrc tmux.conf vimrc"

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

# Set up vim to work as desired
# Set up vundle
if [ ! -d ~/.vim/bundle/Vundle.vim ]; then
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi
# Set up plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
# Use Vundle and Plug to install plugins
(sleep 10; echo ':q') | vim -S <(cat <<EOF
PlugInstall
VundleInstall
EOF
) 2> /dev/null
