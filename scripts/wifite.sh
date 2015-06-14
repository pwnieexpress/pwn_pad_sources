#!/bin/bash
# Script to run Wifite
clear

. /opt/pwnix/pwnpad-scripts/px_functions.sh

if quiet_one=1 f_validate_one wlan1mon; then
  interface=wlan1mon
elif f_validate_one wlan1; then
  interface=wlan1
fi

if [ -n "$interface" ]; then

cd /opt/pwnix/captures/wpa_handshakes/

clear
#wifite currently cannot put a device in monitor mode,
#however, it seems to cleanly handle if a device is already
#new airmon-ng won't make duplicate interfaces, so run it just to make sure we have a monitor
if [ "$interface" = "wlan1" ]; then
  airmon-ng start wlan1 &> /dev/null
fi
wifite

if [ -d hs ]; then
  mv hs/* .
  rm -r hs/
fi

if [ -f cracked.txt ]
then
  mv cracked.txt ../passwords/
fi

hardw=`/system/bin/getprop ro.hardware`
if [[ "$hardw" == "deb" || "$hardw" == "flo" ]]; then
  PHY=$(cat /sys/class/net/wlan1mon/phy80211/name)
  iw dev wlan1mon del
  iw phy $PHY interface add wlan1 type station
else
  airmon-ng stop wlan1mon &> /dev/null
fi
ifconfig wlan1 down &> /dev/null

fi
