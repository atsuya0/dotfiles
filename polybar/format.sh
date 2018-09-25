declare -A colors=(
  ['bg']='#2b303b'
  ['fg']='#c0c5ce'
  ['black']='#65737e'
  ['red']='#bf616a'
  ['green']='#a3be8c'
  ['yellow']='#ebcb8b'
  ['blue']='#5597d9'
  ['magenta']='#b48ead'
  ['cyan']='#96b5b4'
  ['white']='#eff1f5'
)

function text() {
  echo %{F$(color $1)}
}

function underline() {
  echo %{u$(color $1)}
}

function fg() {
  echo "$(text $1)$(underline $1)"
}

function color() {
  echo ${colors[$1]}
}
