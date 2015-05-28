#!/bin/bash
#Description: Script to watch strings go by in real time

include_cell=1
message="sniff on"
. /opt/pwnix/pwnpad-scripts/px_interface_selector.sh

f_savecap(){

  clear
  echo
  echo "Save log to /opt/pwnix/captures/stringswatch?"
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
  filename=/opt/pwnix/captures/stringswatch/strings$(date +%F-%H%M).log
  tshark -i $interface -q -w - | strings -n 8 | tee $filename
}

f_no(){
  tshark -i $interface -q -w - | strings -n 8
}

f_interface
f_savecap
