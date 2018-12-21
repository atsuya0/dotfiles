# The amount of transferred data after turning on the power.
function dtr() {
  cat /proc/net/dev | awk \
    '{if(match($0, /wlp4s0/)!=0) print "Wifi        : Receive",$2/(1024*1024),"MB","|","Transmit",$10/(1024*1024),"MB"} \
    {if(match($0, /bnep0/)!=0) print "Bluetooth Tethering : Receive",$2/(1024*1024),"MB","|","Transmit",$10/(1024*1024),"MB"}'
}

function cc() { # Character Counter
  [[ -s $1 ]] && cat $1 | sed ':a;N;$!ba;s/\n//g' | wc -m
}

function colors(){
  for fore in {30..37}; do
    echo "\e[${fore}m \\\e[${fore}m \e[m"
    for mode in 1 4 5; do
      echo -n "\e[${fore};${mode}m \\\e[${fore};${mode}m \e[m"
      for back in {40..47}; do
        echo -n "\e[${fore};${back};${mode}m \\\e[${fore};${back};${mode}m \e[m"
      done
      echo
    done
    echo
  done
}

function fonts() {
  for i in {$(($1 * 1000))..$(($1 * 1000 + 2000))}; do
    echo -n -e "$(printf '\\u%x' $i) "
  done
}
