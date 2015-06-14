#!/bin/bash
#Description: Script to watch strings go by in real time
clear

#this block controls the features for px_interface_selector
include_cell=1
. /opt/pwnix/pwnpad-scripts/px_functions.sh

f_savecap(){

  printf "\nSave log to /opt/pwnix/captures/stringswatch?\n\n"
  printf "1. Yes\n"
  printf "2. No\n\n"

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
