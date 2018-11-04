#!/usr/bin/bash

# [todo] graphic driver(xf86-video-intel)のinstall

function install_packages() {
  sudo pacman -S --needed --noconfirm \
    $(cat $(dirname $0)/package.list | sed 's/#.*//;s/ //g;/^$/d')
  setup_packages
}

function setup_packages() {
  type zsh &> /dev/null \
    && chsh -s $(which zsh)
  type pip &> /dev/null \
    && pip install --upgrade neovim
  type lightdm &> /dev/null \
    && sudo systemctl enable lightdm.service \
    && sed -i 's/^\(ENV=\)\(lightdm-gtk-greeter\)/\1env GTK_THEME=Adwaita:dark \2/' /usr/share/xgreeters/lightdm-gtk-greeter.desktop
/usr/share/xgreeters/lightdm-gtk-greeter.desktop
  type tlp &> /dev/null \
    && sudo systemctl enable tlp.service tlp-sleep.service \
    && sudo systemctl mask systemd-rfkill.service systemd-rfkill.socket
  add_docker_group
}

function add_docker_group() {
  groups | grep docker \
    && sudo groupadd docker \
    && sudo gpasswd -a $(whoami) docker
}

function install_fonts() {
  local font="${HOME}/.local/share/fonts/"
  local fira_code='https://github.com/tonsky/FiraCode/raw/master/distr/ttf'
  local hack='https://github.com/source-foundry/Hack/raw/master/build/ttf'
  local faces=('Regular' 'Bold' 'Italic')
  mkdir -p ${font}

  for face in ${faces[@]}; do
    curl -fsSL ${fira_code}/{FiraCode-${face}.ttf} -o ${font}/#1
    curl -fsSL ${hack}/{Hack-${face}.ttf} -o ${font}/#1
  done

  fc-cache
}

function set_time() {
  sudo systemctl start systemd-timesyncd
  sudo systemctl enable systemd-timesyncd
  sudo timedatectl set-timezone Asia/Tokyo
}

function set_locale() {
  sudo sed -i 's/^#\(ja_JP.UTF-8.*\)$/\1/' /etc/locale.gen \
    && sudo locale-gen \
    && sudo localectl set-locale ja_JP.UTF-8 \
  sudo localectl set-x11-keymap jp || sudo localectl set-keymap jp
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

function download_packages_from_aur() {
  local packages=(
    'nvm'
    'webstorm'
    'visual-studio-code-bin'
    'typora'
  )

  for package in ${packages[@]}; do
    curl -fsSLO "https://aur.archlinux.org/cgit/aur.git/snapshot/${package}.tar.gz" \
      && tar -xzf ${package} \
      && rm ${package}
  done
}

function main() {
  [[ $(id -u) -eq 0 ]] && return 1
  [[ $# -eq 0 ]] && echo 'A hostname is required as an argument.' && return 1

  sudo sed -i 's/^#\(Color\)$/\1/' /etc/pacman.conf
  sudo pacman -Syu --noconfirm
  sudo hostnamectl set-hostname $1
  install_packages
  set_time
  set_locale
  set_touchpad
  install_fonts
  download_packages_from_aur
}

main $@
