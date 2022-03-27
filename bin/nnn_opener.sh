#!/usr/bin/env bash

set -euCo pipefail

case ${1##*.} in
  'txt'|'md'|'sh'|'go'|'py'|'yaml'|'json' )
    ${EDITOR} $1
  ;;
  'jpg'|'png' )
    feh $1 &> /dev/null
  ;;
  'mp4' )
    vlc $1 &> /dev/null
  ;;
  * )
    google-chrome-stable $1 &> /dev/null
  ;;
esac
