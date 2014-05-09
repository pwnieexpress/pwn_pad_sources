#!/bin/sh +x
# /usr/bin/macchanger --help
# Roll MAC address and hostname

# Get interface to change MAC address of
f_interface(){
  clear
  echo "Select which interface to randomly roll MAC of [1-3]:"
  echo
  echo "1. eth0  (USB Ethernet adapter)"
  echo "2. wlan0  (internal Wifi)"
  echo "3. wlan1  (USB TP-Link adapter)"
  echo
  read -p "Choice: " interfacechoice

  case $interfacechoice in
    1) interface=eth0 ;;
    2) interface=wlan0 ;;
    3) interface=wlan1 ;;
    *) f_interface ;;
  esac
}

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

f_run(){
  f_interface

  ifconfig $interface down

  f_roll_mac
  f_roll_hostname

  ifconfig $interface up
  ifconfig $interface
}

f_run
