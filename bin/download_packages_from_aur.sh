#!/usr/bin/env bash

set -euCo pipefail

# $1: package_name
function is_new_version() {
  [[ $# -eq 0 ]] && { echo 'missing argument'; return 1; }

  local -a installed_pkg_ver
  mapfile installed_pkg_ver < <(get_installed_pkg_ver $1)
  [[ ${#installed_pkg_ver[@]} -eq 0 ]] \
    && { echo "$1 does not exist"; return 1; }

  local -a current_pkg_ver
  mapfile current_pkg_ver < <(fetch_current_pkg_ver $1)
  [[ ${#current_pkg_ver[@]} -eq 0 ]] \
    && { echo "$1 does not exist"; return 1; }

  [[ ${#installed_pkg_ver[@]} -ne ${#current_pkg_ver[@]} ]] \
    && { echo 'package version format is different.'; return 1; }

  local i
  for (( i=0; i < ${#installed_pkg_ver[@]}; i++ )); do
    [[ ${installed_pkg_ver[$i]} -ne ${current_pkg_ver[$i]} ]] \
      && return 0
  done

  return 1
}

# $1: package_name
function get_installed_pkg_ver() {
  [[ $# -eq 0 ]] && { echo 'missing argument'; return 1; }

  pacman -Qi $1 2> /dev/null \
    | grep '^Version' \
    | tr -d '[:space:]' \
    | cut -d: -f2 \
    | tr '[:punct:]' '\n' \
    || return 1
}

# $1: package_name
function fetch_current_pkg_ver() {
  [[ $# -eq 0 ]] && { echo 'missing argument'; return 1; }

  curl -fsSL "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=$1" \
    2> /dev/null | grep '^pkgver=\|^pkgrel=' | cut -d '=' -f2 | tr '.' '\n' \
    || return 1
}

# $1: package_name, $2: directory
function download_package() {
  [[ $# -eq 0 ]] && { echo 'missing argument'; return 1; }

  local -r pkg_file_name="$1.tar.gz"
  local -r pkg_path="$2/$1"
  curl -fsSL "https://aur.archlinux.org/cgit/aur.git/snapshot/${pkg_file_name}" \
    -o ${pkg_path} \
    && tar -xzf ${pkg_path} \
    && rm ${pkg_path}
}

function main() {
  export LANG=C

  local -ar packages=(
    'nvm'
    'chromium-widevine'
  )

  local -r dir="build_$(date +%T)"
  [[ -e ${dir} ]] && return 1 || mkdir ${dir}

  local package
  for package in "${packages[@]}"; do
    is_new_version ${package} && download_package ${package} ${dir}
  done

  [[ -n $(find ${dir} -maxdepth 0 -type d -empty) ]] \
    && rmdir ${dir}
}

main $@
