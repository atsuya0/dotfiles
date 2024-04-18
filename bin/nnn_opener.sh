#!/usr/bin/env bash

set -euCo pipefail

case ${1##*.} in
  'txt'|'md'|'sh'|'go'|'py'|'yaml'|'json' )
    ${EDITOR} "$1"
  ;;
  'jpg'|'png'|'webp' )
    #feh $1 &> /dev/null
    qlmanage -p "$1" &> /dev/null
  ;;
  'mp4'|'webm' )
    vlc "$1" &> /dev/null
  ;;
  * )
    google-chrome-stable $1 &> /dev/null
  ;;
esac
