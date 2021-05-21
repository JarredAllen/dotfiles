#!/bin/bash

HOME_DOTFILES="bash_aliases bashrc tmux.conf vimrc"

HERE=$(dirname "$0")

# Copy dotfiles from here to the home directory
if [ -n "$1" ]; then
    HOME="$1"
fi
echo "Deploying to $HOME..."

for file in $HOME_DOTFILES; do
    cp -uv "$HERE/$file" "$HOME/.$file"
done

# Set up vim to work as desired
# Set up vundle
if [ ! -d ~/.vim/bundle/Vundle.vim ]; then
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi
# Set up plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
