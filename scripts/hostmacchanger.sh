#!/bin/sh +x
#/usr/bin/macchanger --help
#Roll MAC address and hostname

#get Interface to change mac address of:
#!/bin/bash
#script to select interface for sniffing / stripping

##################################################
f_interface(){
  clear
  echo
  echo
  echo "Select which interferace to randomly roll mac of? (1-3):"
  echo
  echo "1. eth0  (USB ethernet adapter)"
  echo "2. wlan0  (Internal Nexus Wifi)"
  echo "3. wlan1  (USB TPlink Atheros)"
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
  echo "[+] Rolling MAC address of wlan0 to something random..."
  echo "[+] To specify MAC to spoof run sudo macchanger -m xx:xx:xx:xx:xx:xx"

  macchanger -r $interface
  sleep 1

  echo "[+] Mac is now rolled!"
}

f_roll_hostname(){
  echo "[+] Rolling hostname for further obscuring..."
  mac=$(ifconfig $interface |grep HWaddr |awk '{print$5}' |awk -F":" '{print$1$2$3$4$5$6}')
  hn=$mac
  sudo hostname $hn
  echo "[+] Hostname has been  updated!"
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
  echo "[+] MAC for $interface and Hostname have been updated"
}

f_run
