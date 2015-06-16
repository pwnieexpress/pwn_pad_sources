#!/bin/bash
# Tshark script for sniffing on available interfaces
clear

#this block controls the features for px_interface_selector
include_cell=1
. /opt/pwnix/pwnpad-scripts/px_functions.sh

f_savecap(){
  printf "\nSave packet capture to /opt/pwnix/captures/tshark?\n\n"
  printf "1. Yes\n"
  printf "2. No\n\n"
  read -p "Choice: " saveyesno

  case $saveyesno in
    1) f_yes ;;
    2) f_no ;;
    *) f_savecap ;;
  esac
}

#########################################
f_yes(){
  filename=tshark$(date +%F-%H%M).cap
  tshark -i $interface -w /opt/pwnix/captures/tshark/$filename -P
}

#########################################
f_no(){
  tshark -i $interface
}

f_interface
ip link set $interface up
f_savecap
