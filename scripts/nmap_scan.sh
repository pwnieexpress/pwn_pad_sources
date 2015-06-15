#!/bin/bash
# Script to scan current network
clear

#this block controls the features for px_interface_selector
include_monitor=0
require_ip=1
message="scan on"
. /opt/pwnix/pwnpad-scripts/px_functions.sh

f_scan(){

  network=$(ifconfig $interface| awk -F ":"  '/inet addr/{split($2,a," ");print a[1]}'|awk -F'.' '{print $1"."$2"."$3"."}')
  cd /opt/pwnix/captures/nmap_scans/

  filename1="/opt/pwnix/captures/nmap_scans/host_scan_$(date +%F-%H%M).txt"
  filename2="/opt/pwnix/captures/nmap_scans/service_scan_$(date +%F-%H%M).txt"

  nmap -sP $network* |tee $filename1
  printf "\nHostscan saved to $filename1\n\n"

  printf "[?] Run a service scan against the discovered?\n\n"
  printf "1. Yes\n"
  printf "2. No\n\n"

  scanagain=$(f_one_or_two)

  if [ $scanagain -eq 1 ]; then
    nmap -sV $network* |tee $filename2
    printf "\nHostscan saved to $filename2\n\n"
  fi
}

f_interface
f_scan
