#!/bin/bash
# Script to start Kismet wireless sniffer

# Set CTRL-C (break) to bring down wlan1mon interface that Kismet creates
trap f_endclean INT
trap f_endclean KILL

# Put kismet_ui.conf into position if first run
f_uicheck(){
  if [ ! -f /root/.kismet/kismet_ui.conf ]; then
    mkdir /root/.kismet
    cp /etc/kismet/kismet_ui.conf /root/.kismet/
  fi
}

# Check for BlueNMEA then start gpsd to log GPS data
f_gps_check(){

  ps ax |grep bluenmea |grep -v grep &> /dev/null
  GPS_STATUS=$?

  if [ $GPS_STATUS -eq 0 ]; then
    gpsd -n -D5 tcp://localhost:4352
  fi
}

f_endclean(){
  ifconfig wlan1mon down &> /dev/null
  ifconfig wlan1 down &> /dev/null
  iw dev wlan1mon del &> /dev/null

  if [ $GPS_STATUS -eq 0 ]; then
    killall -9 gpsd
  fi
}

clear
echo
echo  "Kismet captures saved to /opt/pwnix/captures/wireless/"
echo

wait 3

cd /opt/pwnix/captures/wireless/

f_uicheck
f_gps_check
kismet
f_endclean

