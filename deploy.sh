#!/bin/bash
set -euo pipefail

# The dotfiles directly in my home to copy out
HOME_DOTFILES="bash_aliases bashrc tmux.conf vimrc"
# Directories in my home's .config directory
HOME_CONFIG_ENTRIES="git ripgrep.conf i3"
HOME_VIM_DIRS="after"
CARGO_BINARIES=(bat cargo-outdated cargo-tree cargo-udeps difftastic fd-find ripgrep sd)

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
        -*) # Unsupported flags
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
for dir in $HOME_CONFIG_ENTRIES; do
    cp $CP_ARGS -R "$HERE/$dir" "$TARGET/.config/"
done
# Copy .vim subdirs recursively to the .vim directory
for dir in $HOME_VIM_DIRS; do
    cp $CP_ARGS -R "$HERE/vim/$dir" "$HOME/.vim/"
done
# Copy binaries into ~/bin
cp $CP_ARGS -R "$HERE/bin" "$HOME"
# Install z
curl https://raw.githubusercontent.com/rupa/z/master/z.sh > "$HOME/bin/z.sh"

# Set some global git configuration variables
# TODO Figure out how to arrange these variables in a more easily readable/editable manner
GIT_CONFIG=$'pull.ff only\nuser.name "Jarred Allen"\ncore.excludesfile ~/.config/git/ignore\ndiff.external difft'
bash <(while IFS=$'\n' read -r option; do echo "git config --file \"$TARGET/.gitconfig\" --replace-all $option"; done <<< "$GIT_CONFIG")

# If cargo is present, update all files installed through it
# And then install the ones that I like to use
if command -v cargo; then
    cargo install --list | grep -E '^[a-z0-9_-]+ v[0-9.]+:$' | cut -f1 -d' ' | xargs cargo install
    cargo install "${CARGO_BINARIES[@]}"
else
    echo "Not installing cargo programs because cargo could not be found"
    echo "Recommend installing cargo by visiting <https://www.rust-lang.org/tools/install>"
fi

# Set up vim to work as desired
# Set up vundle
if [ -d ~/.vim/bundle/Vundle.vim ]; then
    printf "Updating Vundle: "
    (cd ~/.vim/bundle/Vundle.vim && git pull)
else
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi
# Use Vundle to install plugins, and use CoC to install language servers
# TODO figure out how to wait until it finishes, instead of having a fixed 20-second timer
# TODO figure out why it fails and fix it, instead of asserting that it didn't
(sleep 20; echo ':q') | vim -S <(cat <<EOF
PluginInstall!
CocInstall coc-clangd coc-json coc-julia coc-python coc-rust-analyzer
EOF
) 2> /dev/null || true

if command -v npm; then
    if command -v yarn; then
        true
    else
        echo "Node installed, but yarn not installed"
        echo "Installing yarn..."
        sudo npm install --global yarn
    fi
else
    echo "Npm not installed, recommend installing node"
fi

# Build coc.nvim so it will work
echo "Building coc.nvim"
if (which yarn); then
    (cd ~/.vim/bundle/coc.nvim && yarn install)
else
    echo "No yarn install found, not building coc.nvim"
fi
