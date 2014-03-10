#!/bin/bash
# Script to start Kismet wireless sniffer

# Set term type to vt100 for now, only thing that displays curses properly atm
# export TERM=vt100

# Set ctrl c (break) to gracefully stop wlan1mon that kismet creates

trap f_endclean INT
trap f_endclean KILL

# Place kismet_ui.conf in proper place for kismet if first time running kismet
f_uicheck(){
  if [ ! -f /root/.kismet/kismet_ui.conf ]; then
    mkdir /root/.kismet
    cp /etc/kismet/kismet_ui.conf /root/.kismet/
  fi
}

# Function to check for BlueNMEA and start GPSD if present for GPS logging
f_gps_check(){

  ps ax |grep bluenmea |grep -v grep &> /dev/null
  GPS_STATUS=$?

  if [ $GPS_STATUS -eq 0 ]; then
    gpsd -n -D5 tcp://localhost:4352
  fi
}

f_endclean(){
  ifconfig wlan1mon down
  ifconfig wlan1 down


  if [ $GPS_STATUS -eq 0 ]; then
    killall -9 gpsd
  fi
}

clear
echo
echo  "Kismet captures saved to /opt/pwnix/captures/wireless/"
echo
echo

wait 3

cd /opt/pwnix/captures/wireless/

f_uicheck
f_gps_check
kismet
f_endclean

