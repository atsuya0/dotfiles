function bluetooth_pairing() {
  systemctl is-active bluetooth &> /dev/null \
    || sudo systemctl start bluetooth.service
  () {
    echo 'power on'
    sleep 1
    echo "connect $1"
    sleep 5
    echo 'quit'
  } $1 | bluetoothctl
}

# Bluetooth tethering
# Do not use the anaconda's dbus-send.
# The AC_CF_85_B7_9D_9A is MAC address of the smartphone。
function bluetooth_tethering() {
  local -r addr='58:CB:52:07:5D:8F'

  bluetooth_pairing ${addr}
  /usr/bin/dbus-send --system --type=method_call --dest=org.bluez \
    "/org/bluez/hci0/dev_${addr//:/_}" org.bluez.Network1.Connect string:'nap' \
    && sleep 1 \
    && sudo dhcpcd bnep0
}

function connect_earphone() {
  local -Ar mac_addresses=(
    ['soundpeats_q35']='51:53:5B:00:D8:0E'
    ['1more']='0C:73:EB:38:76:E9'
    ['soundcore_life_u2']='E8:07:BF:AF:58:23'
    ['pixel_buds_pro']='24:29:34:B4:78:DB'
  )
  local -r key=$(print -C 1 ${(k)mac_addresses[@]} | fzf --select-1)
  [[ -n ${mac_addresses[${key}]} ]] && bluetooth_pairing ${mac_addresses[${key}]}
}
alias ce='connect_earphone'

function disconnect() {
  () {
    echo 'disconnect'
    sleep 1
    echo 'quit'
  } $1 | bluetoothctl
}

function reset_bluetooth() {
  sudo rmmod btusb
  sudo modprobe btusb
}
