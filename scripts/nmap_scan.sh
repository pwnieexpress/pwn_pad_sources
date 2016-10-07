#!/bin/bash
# Script to scan current network
# Set the prompt to the name of the script
PS1=${PS1//@\\h/@nmap}
clear

# This block controls the features for px_interface_selector
include_monitor=0
require_ip=1
message="scan on"
. /opt/pwnix/pwnpad-scripts/px_functions.sh

f_scan(){

  networks=$(ip route | grep -E "^([0-9]{1,3}\.){3}[0-9]{1,3}.*${interface}" | awk '{print $1}' | sort -u)
  cd /opt/pwnix/captures/nmap_scans/

  filename1="/opt/pwnix/captures/nmap_scans/host_scan_$(date +%F-%H%M).txt"
  filename2="/opt/pwnix/captures/nmap_scans/service_scan_$(date +%F-%H%M).txt"

  for network in ${networks}; do
    nmap -sP $network | tee -a $filename1
  done

  printf "\nHostscan saved to $filename1\n\n"

  printf "[?] Run a service scan against the discovered?\n\n"
  printf "1. Yes\n"
  printf "2. No\n\n"

  scanagain=$(f_one_or_two)

  if [ $scanagain -eq 1 ]; then
    for network in ${networks}; do
      nmap -sV $network | tee -a $filename2
    done
    printf "\nHostscan saved to $filename2\n\n"
  fi
}

f_interface
f_scan
