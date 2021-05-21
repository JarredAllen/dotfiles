#!/bin/bash

HOME_DOTFILES="bash_aliases bashrc tmux.conf vimrc"

HERE=$(dirname "$0")

if [ -n "$1" ]; then
    HOME="$1"
fi
echo "Deploying to $HOME..."

for file in $HOME_DOTFILES; do
    cp -uv "$HERE/$file" "$HOME/.$file"
done
