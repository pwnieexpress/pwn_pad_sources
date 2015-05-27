#!/bin/bash
# Script to run Wifite

cd /opt/pwnix/captures/wpa_handshakes/

clear
wifite

if [ -d hs ]; then
  mv hs/* .
  rm -r hs/
fi

if [ -f cracked.txt ]
then
  mv cracked.txt ../passwords/
fi

if [[ "$hardw" == "deb" || "$hardw" == "flo" ]]; then
  iw dev wlan1mon del
  iw phy $(cat /sys/class/net/wlan0/phy80211/name) interface add wlan1 type station
else
  airmon-ng stop wlan1mon &> /dev/null
fi
ifconfig wlan1 down &> /dev/null

