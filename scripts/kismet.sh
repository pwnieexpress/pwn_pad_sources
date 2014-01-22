#!/bin/bash
# Script to start Kismet wireless sniffer

# Set term type to vt100 for now, only thing that displays curses properly atm
# export TERM=vt100

# Set ctrl c (break) to gracefully stop wlan1mon that kismet creates

trap f_endclean INT
trap f_endclean KILL

f_endclean(){
  ifconfig wlan1mon down
  ifconfig wlan1 down
}

clear
echo
echo  "Kismet captures saved to /opt/pwnix/captures/wireless/"
echo
echo

wait 3

cd /opt/pwnix/captures/wireless/

kismet

f_endclean

