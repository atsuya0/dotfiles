#!/usr/bin/bash

# [todo] graphic driver(xf86-video-intel)のinstall

function install_min_packages() {
  sudo pacman -S --noconfirm xorg-server xorg-xinit xorg-xbacklight \
    otf-ipafont noto-fonts-emoji fcitx-mozc fcitx-gtk3 fcitx-configtool \
    alsa-utils pulseaudio \
    termite rxvt-unicode \
    zsh zsh-completions zsh-syntax-highlighting \
    neovim python-neovim python-pip xsel \
    lightdm light-locker lightdm-gtk-greeter \
    pacman-contrib feh tree ranger chromium unzip iw \
    && chsh -s $(which zsh) \
    && pip install --upgrade neovim \
    && sudo systemctl enable lightdm \
    && sudo sed -i \
      's/^Exec=.*/Exec=env GTK_THEME=Adwaita:dark lightdm-gtk-greeter/' \
      /usr/share/xgreeters/lightdm-gtk-greeter.desktop
}

function install_option_packages() {
  sudo pacman -S --noconfirm fzf tmux openssh docker docker-compose xorg-xrandr \
    cmus libmad bluez bluez-utils pulseaudio-bluetooth libmtp ntfs-3g \
    xorg-server-xephyr jq go rustup dosfstools w3m neofetch \
    virtualbox scrot alacritty

  add_docker_group
}

function add_docker_group() {
  groups | grep docker \
    && sudo groupadd docker \
    && sudo gpasswd -a $(whoami) docker
}

function install_i3() {
  sudo pacman -S --noconfirm i3-wm i3blocks i3lock rofi
}
function install_jwm() {
  sudo pacman -S --noconfirm jwm xterm
}

function install_fonts() {
  local font="${HOME}/.local/share/fonts/"
  local fira_code='https://github.com/tonsky/FiraCode/raw/master/distr/ttf'
  local hack='https://github.com/source-foundry/Hack/raw/master/build/ttf'
  local faces=('Regular' 'Bold' 'Italic')
  mkdir -p ${font}

  for face in ${faces[@]}; do
    curl -L ${fira_code}/{FiraCode-${face}.ttf} -o ${font}/#1
    curl -L ${hack}/{Hack-${face}.ttf} -o ${font}/#1
  done

  fc-cache
}

function install_packages_for_virtualbox() {
  sudo pacman -S --noconfirm xf86-video-vesa xf86-video-fbdev virtualbox-guest-utils virtualbox-guest-modules-arch
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
  curl -LO https://aur.archlinux.org/cgit/aur.git/snapshot/nvm.tar.gz
  curl -LO https://aur.archlinux.org/cgit/aur.git/snapshot/webstorm.tar.gz
}

function main() {
  sudo sed -i 's/^#\(Color\)$/\1/' /etc/pacman.conf

  sudo pacman -Syu
  sudo hostnamectl set-hostname $1
  set_time
  set_locale
  set_touchpad
  install_min_packages
  install_fonts

  if [[ $1 == 'virtualbox' ]]; then
    install_jwm
    install_packages_for_virtualbox
    sudo systemctl enable dhcpcd@enp0s3
  else
    install_i3
    install_option_packages
  fi
}

[[ $(id -u) -eq 0 ]] && return 1
[[ $# -eq 0 ]] && echo 'hostname' && return 1
main $1
