#!/usr/bin/bash

# zsh
cat << "EOF" > ${HOME}/.zshenv
export ZDOTDIR="${HOME}/.zsh"
source ${ZDOTDIR}/.zshenv
EOF

zsh="${HOME}/.zsh"
dot="${HOME}/dotfiles/zsh"
mkdir "${zsh}"
ln "${dot}/zshenv" "${zsh}/.zshenv"
ln "${dot}/zshrc" "${zsh}/.zshrc"
ln "${dot}/zlogin" "${zsh}/.zlogin"

# vim
nvim="${XDG_CONFIG_HOME}/nvim"
dein="${HOME}/.cache/dein/toml"
dot="${HOME}/dotfiles/vim"
mkdir "${nvim}"
mkdir -p "${dein}"
ln "${dot}/init.vim" "${nvim}/"
ln "${dot}/dein.toml" "${dein}/"
ln "${dot}/dein_lazy.toml" "${dein}/"

# mlterm
mlterm="${HOME}/.mlterm"
dot="${HOME}/dotfiles/mlterm"
mkdir "${HOME}/.mlterm"
ln "${dot}/aafont" "${mlterm}/"
ln "${dot}/color" "${mlterm}/"
ln "${dot}/key" "${mlterm}/"
ln "${dot}/main" "${mlterm}/"

# i3
dot="${HOME}/dotfiles/i3"
mkdir "${XDG_CONFIG_HOME}/{i3,i3blocks}"
ln "${i3}/i3" "${XDG_CONFIG_HOME}/i3/config"
ln "${i3}/i3blocks" "${XDG_CONFIG_HOME}/i3blocks/config"
ln "${i3}/battery.sh" "${XDG_CONFIG_HOME}/i3blocks/"

# x11
dot="${HOME}/dotfiles/x11"
ln "${x11}/Xmodmap" "${HOME}/.Xmodmap"
ln "${x11}/xprofile" "${HOME}/.xprofile"

# rofi
rofi="${XDG_CONFIG_HOME}/rofi"
dot="${HOME}/dotfiles/rofi"
mkdir "${rofi}"
ln "${rofi}/rofi" "${rofi}/config"
ln "${rofi}/rofi_system.sh" "${rofi}/"
