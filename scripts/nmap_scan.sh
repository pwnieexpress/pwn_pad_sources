#!/bin/bash
# Script to scan current network

messages="scan on"
include_monitor=0
. /opt/pwnix/pwnpad-scripts/px_interface_selector.sh

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
