#!/usr/bin/env bash

# [todo] graphic driver(xf86-video-intel)のinstall

set -euCo pipefail

function add_docker_group() {
  groups | grep docker \
    && sudo groupadd docker \
    && sudo gpasswd -a $(whoami) docker
}

function setup_packages() {
  which zsh &> /dev/null \
    && chsh -s $(which zsh)

  which pip &> /dev/null \
    && pip install --user pynvim

  which lightdm &> /dev/null \
    && sudo systemctl enable lightdm.service \
    && sed -i \
        's/^\(ENV=\)\(lightdm-gtk-greeter\)/\1env GTK_THEME=Adwaita:dark \2/' \
        /usr/share/xgreeters/lightdm-gtk-greeter.desktop

  which tlp &> /dev/null \
    && sudo systemctl enable tlp.service tlp-sleep.service \
    && sudo systemctl mask systemd-rfkill.service systemd-rfkill.socket

  which docker &> /dev/null \
    && add_docker_group
}

# --noconfirm: Bypass any and all “Are you sure?” messages.
# --needed: Do not reinstall the targets that are already up-to-date.
function install_packages() {
  local -r file="${DOTFILES}/doc/packages.txt"
  [[ -s ${file} ]] || return 1

  sudo pacman -S --needed --noconfirm \
    $(cat ${file} | sed 's/#.*//;s/ //g;/^$/d')
  setup_packages
}

function install_fonts() {
  local -r font_dir="${HOME}/.local/share/fonts/"
  mkdir -p ${font_dir}

  local -ar faces=('Regular' 'Bold' 'Italic')
  local -ar fira_code=('FiraCode' 'https://github.com/tonsky/FiraCode/raw/master/distr/ttf')
  local -ar hack=('Hack' 'https://github.com/source-foundry/Hack/raw/master/build/ttf')

  for face in ${faces[@]}; do
    curl -fsSL ${fira_code[1]}/{${fira_code[0]}-${face}.ttf} -o ${font_dir}/#1
    curl -fsSL ${hack[1]}/{${hack[0]}-${face}.ttf} -o ${font_dir}/#1
  done

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
  cat << "EOF" | sudo tee /etc/X11/xorg.conf.d/40-libinput.conf
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
  install_fonts
}

main $@
