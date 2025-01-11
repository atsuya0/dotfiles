#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Rotate
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖

/opt/homebrew/bin/displayplacer list \
  | tail -1 \
  | /opt/homebrew/opt/gnu-sed/libexec/gnubin/sed \
    's/degree:90"$/degree:0"/;ta;s/degree:0"$/degree:90"/;:a;s/res:\([0-9]*\)x\([0-9]*\)/res:\2x\1/2' \
  | cut -d' ' -f 2- \
  | xargs /opt/homebrew/bin/displayplacer
