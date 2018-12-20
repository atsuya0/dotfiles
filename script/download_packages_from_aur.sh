#!/usr/bin/env bash

set -euCo pipefail

function is_new_version() {
  [[ $# -eq 0 ]] && { echo 'missing argument'; return 2; }

  local -a installed_pkg_ver current_pkg_ver
  installed_pkg_ver=($(get_installed_pkg_ver $1))
  current_pkg_ver=($(fetch_current_pkg_ver $1))
  [[ $? -eq 1 ]] && { echo "$1 does not exist"; return 1; }

  [[ ${#installed_pkg_ver[@]} -ne ${#current_pkg_ver[@]} ]] \
    && { echo 'package version format is different.'; return 2; }

  local i
  for (( i=0; i < ${#installed_pkg_ver[@]}; i++ )); do
    [[ ${installed_pkg_ver[$i]} -ne ${current_pkg_ver[$i]} ]] \
      && return 0
  done

  return 1
}

function get_installed_pkg_ver() {
  [[ $# -eq 0 ]] && { echo 'missing argument'; return 1; }

  pacman -Qi $1 \
    | grep '^Version' \
    | tr -d '[:space:]' \
    | cut -d: -f2 \
    | tr '[:punct:]' '\n' \
    || return 1
}

function fetch_current_pkg_ver() {
  [[ $# -eq 0 ]] && { echo 'missing argument'; return 1; }

  curl -fsSL "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=$1" \
    | grep '^pkgver=\|^pkgrel=' | cut -d '=' -f2 | tr '.' '\n' \
    || return 1
}

function download_package() {
  [[ $# -eq 0 ]] && { echo 'missing argument'; return 1; }

  local -r pkg_file="$1.tar.gz"
  curl -fsSLO "https://aur.archlinux.org/cgit/aur.git/snapshot/{${pkg_file}}" \
    && tar -xzf ${pkg_file} \
    && rm ${pkg_file}
}

function main() {
  export LANG=C

  local -ar packages=(
    'nvm'
    'visual-studio-code-bin'
  )

  local -r dir="build_$(date +%T)"
  [[ -e ${dir} ]] && return 1 || mkdir ${dir}

  (
    cd ${dir}
    local package
    for package in ${packages[@]}; do
      is_new_version ${package} && download_package ${package}
    done
  )

  [[ -n $(find ${dir} -maxdepth 0 -type d -empty) ]] \
    && rmdir ${dir}
}

main
