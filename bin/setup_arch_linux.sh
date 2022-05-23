#!/usr/bin/env bash

set -euCo pipefail

function install_my_tools() {
  mkdir ${HOME}/workspace
  (
    cd  ${HOME}/workspace
    git clone https://github.com/atsuya0/scd
    git clone https://github.com/atsuya0/trs
    git clone https://github.com/atsuya0/aurm
    git clone https://github.com/atsuya0/cremem
  )
}

function setup_packages() {
  which zsh &> /dev/null \
    && chsh -s $(type zsh | cut -d' ' -f3)

  which pip &> /dev/null \
    && pip install --user pynvim

  which tlp &> /dev/null \
    && sudo systemctl enable tlp.service tlp-sleep.service \
    && sudo systemctl mask systemd-rfkill.service systemd-rfkill.socket
}

# --noconfirm: Bypass any and all “Are you sure?” messages.
# --needed: Do not reinstall the targets that are already up-to-date.
function install_packages() {
  sed -i '1i Server = http://ftp.jaist.ac.jp/pub/Linux/ArchLinux/$repo/os/$arch' \
    /etc/pacman.d/mirrorlist

  local -r file="${DOTFILES}/doc/packages.txt"
  [[ -s ${file} ]] || return 1

  sudo pacman -S --needed --noconfirm \
    $(cat ${file} | sed 's/#.*//;s/ //g;/^$/d')
  setup_packages

  curl -LO https://aur.archlinux.org/cgit/aur.git/snapshot/google-chrome.tar.gz
  bsdtar xf google-chrome.tar.gz
}

function install_font() {
  local -r font_dir="${HOME}/.local/share/fonts/"
  mkdir -p ${font_dir}

  curl -LO https://github.com/yuru7/HackGen/releases/download/v2.6.3/HackGenNerd_v2.6.3.zip \
    && bsdtar xf HackGenNerd_v2.5.1.zip \
    && rm HackGenNerd_v2.5.1.zip \
    && mv HackGenNerd_v2.5.1/* -t ${font_dir} \
    && rmdir HackGenNerd_v2.5.1

  fc-cache
}

function set_datetime() {
  sudo systemctl start systemd-timesyncd
  sudo systemctl enable systemd-timesyncd
  sudo timedatectl set-timezone Asia/Tokyo
}

function set_locale() {
  sudo sed -i 's/^#\(ja_JP.UTF-8.*\)$/\1/' /etc/locale.gen \
    && sudo locale-gen \
    && sudo localectl set-locale ja_JP.UTF-8 \
  sudo localectl set-x11-keymap jp || sudo localectl set-keymap jp106
}

function set_touchpad() {
  sudo mkdir -p /etc/X11/xorg.conf.d
  cat << "EOF" | sudo tee /etc/X11/xorg.conf.d/40-libinput.conf > /dev/null
Section "InputClass"
  Identifier "libinput touchpad catchall"
  MatchIsTouchpad "on"
  MatchDevicePath "/dev/input/event*"
  Driver "libinput"
  Option "Tapping" "on"
  Option "ClickMethod" "clickfinger"
  Option "TappingButtonMap" "lrm"
  Option "NaturalScrolling" "true"
  Option "TappingDragLock" "false"
  Option "TappingDrag" "false"
EndSection
EOF
}


# sudo systemctl start systemd-networkd
function set_dhcp() {
  cat << EOF | sudo tee /etc/systemd/network/dhcp.network > /dev/null
[Match]
Name=$(networkctl list | grep ther | tr -s ' ' | cut -d' ' -f 3)

[Network]
DHCP=ipv4
EOF
}

function create_symlink() {
  local -r name=$(basename $(git config --get remote.origin.url))
  local -r root=$(echo ${PWD}${0:1} | sed ":a;s@/[^/]\+\$@@;/${name}$/!ba")

  ls -A ${root}/home | while read -r file; do
    ln -s "${root}/home/${file}" "${HOME}/"
  done

  ls -A ${root}/config | while read -r dir; do
    ln -s "${root}/config/${dir}" "${HOME}/.config/"
  done
}

function main() {
  [[ $(id -u) -eq 0 ]] && return 1
  [[ $# -eq 0 ]] \
    && { echo 'A hostname is required as an argument.'; return 1; }

  sudo sed -i 's/^#\(Color\)$/\1/' /etc/pacman.conf
  sudo pacman -Syu --noconfirm
  sudo hostnamectl set-hostname $1
  install_packages
  set_datetime
  set_locale
  set_touchpad
  set_dhcp
  install_font
  sudo sytemctl enable fstrim.timer
  sudo sytemctl enable bluetooth
  create_symlink
}

main $@
