[[ -n ${WSL_INTEROP} ]] && {
  function notify() {
    [[ -f '/mnt/c/Users/atsuy/scripts/notify.ps1' ]] || return 1

    /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe \
      -Sta -NoProfile \
      -WindowStyle Hidden \
      -ExecutionPolicy RemoteSigned \
      -File c:/Users/atsuy/scripts/notify.ps1 \
      $@ '通知'
  }
}
