#!/bin/bash
# Tshark script for sniffing on available interfaces
# Set the prompt to the name of the script
PS1=${PS1//@\\h/@tshark}
clear

# This controls the features for px_interface_selector
include_cell=1
. /opt/pwnix/pwnpad-scripts/px_functions.sh

f_savecap() {
  printf "\nSave packet capture to /opt/pwnix/captures/tshark?\n\n"
  printf "1. Yes\n"
  printf "2. No\n\n"
  read -p "Choice: " saveyesno

  case $saveyesno in
    1) flags="-w tshark-$(date +%F-%H%M).cap -P" ;;
    2) flags="" ;;
    *) f_savecap ;;
  esac
}

f_interface
ip link set $interface up
f_savecap

if [ ! -d /opt/pwnix/captures/tshark ]; then
  mkdir -p /opt/pwnix/captures/tshark
fi
cd /opt/pwnix/captures/tshark
tshark -i "${interface}" ${flags}
