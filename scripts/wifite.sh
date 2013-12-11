#!/bin/bash
#Script to run wifite 

cd /opt/pwnix/captures/wpa_handshakes/

wifite

if [ -d hs ]; then
  mv hs/* .
  rm -r hs/
fi

if [ -f cracked.txt ]
then
  mv cracked.txt ../passwords/
fi

airmon-ng stop mon0
ifconfig wlan1 down

