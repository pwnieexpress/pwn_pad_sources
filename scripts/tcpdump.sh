#!/bin/bash
# Tcpdump script for sniffing on available interfaces

include_cell=1
. /opt/pwnix/pwnpad-scripts/px_interface_selector.sh

f_savecap(){
  clear
  echo
  echo "Save packet capture to /opt/pwnix/captures/tcpdump?"
  echo
  echo "1. Yes"
  echo "2. No"
  echo
  read -p "Choice [1-2]: " saveyesno

  case $saveyesno in
    1) f_yes ;;
    2) f_no ;;
    *) f_savecap ;;
  esac
}

f_yes(){
  filename=/opt/pwnix/captures/tcpdump/tcpdump_$(date +%F-%H%M).cap
  tcpdump -l -s0 -vvv -e -xx -i $interface | tee $filename
}

f_no(){
  tcpdump -s0 -vvv -e -i $interface
}

f_interface
f_savecap
