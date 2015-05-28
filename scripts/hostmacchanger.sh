#!/bin/bash
# /usr/bin/macchanger --help
# Roll MAC address and hostname

message="randomly roll the MAC address of"
. /opt/pwnix/pwnpad-scripts/px_interface_selector.sh

f_roll_mac(){
  echo
  echo "[+] Rolling MAC address to something random..."
  echo "[-] To specify MAC to spoof run sudo macchanger -m xx:xx:xx:xx:xx:xx"

  macchanger -r $interface
  sleep 1
  echo
  echo "[!] MAC address has been rolled!"
}

f_roll_hostname(){
  echo "[+] Rolling hostname for further obfuscation..."
  mac=$(ifconfig $interface |grep HWaddr |awk '{print$5}' |awk -F":" '{print$1$2$3$4$5$6}')
  hn=$mac
  sudo hostname $hn
  echo "[!] Hostname has been changed!"
  echo "[+] New hostname: $hn"
  echo
}

f_interface

ifconfig $interface down

f_roll_mac
f_roll_hostname

ifconfig $interface up
ifconfig $interface
