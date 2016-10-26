#!/usr/bin/env bash
# Quick script to bootstrap symlinks for dotfiles

CONFS=(gitconfig screenrc shell.aliases tmux.conf vim vimrc Xdefaults Xresources zshrc zshrc.local)

function link_this_kthx() {
    local sourcething="$1"
    local destthing="$2"

    if [[ ! -e "${homepath}" ]]
    then
        echo "Linking ${sourcething} as ${destthing}"
        ln -s "${sourcething}" "${destthing}"
    else
        echo "${destthing} already exists. Skipping..."
    fi
}

for f in "${CONFS[@]}"
do
    sourcepath="${HOME}/sandbox/dotfiles/${f}"
    homepath="${HOME}/.${f}"
    link_this_kthx "$sourcepath" "$homepath"
done
