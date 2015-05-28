#!/bin/bash
# Tshark script for sniffing on available interfaces

include_cell=1
. px_interface_selector.sh

f_savecap(){
  clear
  echo
  echo "Save packet capture to /opt/pwnix/captures/tshark?"
  echo
  echo "1. Yes"
  echo "2. No"
  echo
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
f_savecap
