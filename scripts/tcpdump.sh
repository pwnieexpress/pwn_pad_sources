#!/bin/bash
# Tcpdump script for sniffing on available interfaces
#set the prompt to the name of the script
PS1=${PS1//@\\h/@tcpdump}
clear

#this block controls the features for px_interface_selector
include_cell=1
. /opt/pwnix/pwnpad-scripts/px_functions.sh

f_savecap(){
  printf "\nSave packet capture to /opt/pwnix/captures/tcpdump?\n\n"
  printf "1. Yes\n"
  printf "2. No\n\n"
  read -p "Choice [1-2]: " saveyesno

  trap f_hangup SIGHUP

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

f_hangup(){
  pkill -f 'tcpdump -s0 -vvv -e -i ${interface}'
  exit 1
}

f_interface
ip link set $interface up
f_savecap
