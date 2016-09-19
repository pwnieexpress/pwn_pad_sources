#abstracted evil ap functions

f_sanity_check(){
  EXIT_NOW=0
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
  if [ -n "$(pgrep -f /system/bin/hostapd)" ]; then
    printf "hostapd[$(pgrep -f /system/bin/hostapd)] is already running, disabling wifi internal option\n"
    return 2
  fi
  if [ "$EXIT_NOW" = "1" ]; then
    return 1
  else
    return 0
  fi
}

f_evilap_type(){
  if [ -x /usr/sbin/hostapd-wpe ]; then
    evilap_type="hostapd"
    #this is set after attack_interface_selector based on user selection
    #evilap_interface="${attack_interface%mon}"
    #evilap_eth="${attack_interface%mon}"
  else
    evilap_type="airbase-ng"
    evilap_interface="wlan1mon"
    evilap_eth="at0"
  fi
}

f_banner() {
  printf "\n[+] Welcome to EvilAP\n\n"
}

select_attack_interface(){
  local include_wired=0
  local include_airbase=0
  local include_usb=0
  local message="to be used as the Evil AP"
  local default_interface="wlan1"
  f_interface
  attack_interface=${interface}
  unset ${interface}
  export attack_interface
}

select_uplink_interface(){
  local include_null=1
  local include_extwifi=0
  local include_monitor=0
  local include_airbase=0
  local include_cell=1
  local include_usb=0 #the computer thinks we are sharing internet, not the other way
  local default_interface=gsm_int
  local require_ip=1
  local message="be used for Internet uplink"
  f_interface
  export interface
}
