#!/bin/bash
# Script to scan current network

f_interface(){
  clear
  echo "Select which interface to scan on [1-4]:"
  echo
  echo "1. eth0  (USB Ethernet adapter)"
  echo "2. wlan0  (internal Wifi)"
  echo "3. wlan1  (USB TP-Link adapter)"
  echo "4. at0  (Use with EvilAP)"
  echo
  read -p "Choice [1-4]: " interfacechoice

  case $interfacechoice in
    1) interface=eth0 ;;
    2) interface=wlan0 ;;
    3) interface=wlan1 ;;
    4) interface=at0 ;;
    *) f_interface ;;
  esac
}

f_one_or_two(){
  read -p "Choice [1-2]: " input
  case $input in
    [1-2]*) echo $input ;;
    *) f_one_or_two ;;
  esac
}

f_scan(){

  network=$(ifconfig $interface| awk -F ":"  '/inet addr/{split($2,a," ");print a[1]}'|awk -F'.' '{print $1"."$2"."$3"."}')
  cd /opt/pwnix/captures/nmap_scans/

  filename1="/opt/pwnix/captures/nmap_scans/host_scan_$(date +%F-%H%M).txt"
  filename2="/opt/pwnix/captures/nmap_scans/service_scan_$(date +%F-%H%M).txt"

  nmap -sP $network* |tee $filename1
  echo
  echo "Hostscan saved to $filename1"
  echo

  echo "[?] Run a service scan against the discovered?"
  echo
  echo "1. Yes"
  echo "2. No"
  echo

  scanagain=$(f_one_or_two)

  if [ $scanagain -eq 1 ]; then
    nmap -sV $network* |tee $filename2
    echo
    echo "Hostscan saved to $filename2"
    echo
    echo
  fi
}

f_interface
f_scan

