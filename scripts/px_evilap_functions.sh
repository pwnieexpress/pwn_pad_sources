#abstracted evil ap functions

f_sanity_check(){
  EXIT_NOW=0
  if [ "${1}" = "external" ]; then
    if [ -n "$(pgrep hostapd-wpe)" ]; then
      printf "hostapd-wpe[$(pgrep hostapd-wpe)] is already running.  Are you already running evilap?\n"
      EXIT_NOW=1
    fi
    if [ -n "$(pgrep airbase-ng)" ]; then
      printf "airbase-ng[$(pgrep airbase-ng)] is already running.  Are you already running evilap?\n"
      EXIT_NOW=1
    fi
    if [ -n "$(pgrep dhcpd)" ]; then
      printf "dhcpd[$(pgrep dhcpd)] is already running.  Are you already running evilap?\n"
      EXIT_NOW=1
    fi
  elif [ "${1}" = "internal" ]; then
    if [ -n "$(pgrep -f /system/bin/hostapd)" ]; then
      printf "hostapd[$(pgrep -f /system/bin/hostapd)] is already running, disabling wifi internal option\n"
      return 2
    fi
  fi
  if [ "$EXIT_NOW" = "1" ]; then
    return 1
  else
    return 0
  fi
}
