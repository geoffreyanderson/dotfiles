#!/usr/bin/env bash
# Quick script to bootstrap symlinks for dotfiles

ln -s "${HOME}/sandbox/dotfiles/gitconfig" "${HOME}/.gitconfig"
ln -s "${HOME}/sandbox/dotfiles/screenrc" "${HOME}/.screenrc"
ln -s "${HOME}/sandbox/dotfiles/shell.aliases" "${HOME}/.shell.aliases"
ln -s "${HOME}/sandbox/dotfiles/tmux.conf" "${HOME}/.tmux.conf"
ln -s "${HOME}/sandbox/dotfiles/vimrc" "${HOME}/.vimrc"
ln -s "${HOME}/sandbox/dotfiles/Xdefaults" "${HOME}/.Xdefaults"
ln -s "${HOME}/sandbox/dotfiles/Xresources" "${HOME}/.Xresources"
ln -s "${HOME}/sandbox/dotfiles/zshrc" "${HOME}/.zshrc"
ln -s "${HOME}/sandbox/dotfiles/zshrc.local" "${HOME}/.zshrc.local"
