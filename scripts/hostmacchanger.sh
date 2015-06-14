#!/bin/bash
# /usr/bin/macchanger --help
# Roll MAC address and hostname
clear

#this block controls the features for px_interface_selector
message="randomly roll the MAC address of"
. /opt/pwnix/pwnpad-scripts/px_functions.sh

f_roll_mac(){
  printf "\n[+] Rolling MAC address to something random...\n"
  printf "[-] To specify MAC to spoof run macchanger -m xx:xx:xx:xx:xx:xx\n"

  macchanger -r $interface
  sleep 1
  printf "\n[!] MAC address has been rolled!\n"
}

f_roll_hostname(){
  printf "[+] Rolling hostname for further obfuscation...\n"
  mac=$(ifconfig $interface |grep HWaddr |awk '{print$5}' |awk -F":" '{print$1$2$3$4$5$6}')
  hn=$mac
  sudo hostname $hn
  printf "[!] Hostname has been changed!\n"
  printf "[+] New hostname: $hn\n\n"
}

f_interface

ifconfig $interface down

f_roll_mac
f_roll_hostname

ifconfig $interface up
ifconfig $interface
