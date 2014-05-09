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

airmon-ng stop mon0 &> /dev/null
ifconfig wlan1 down &> /dev/null

