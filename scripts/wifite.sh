#!/bin/bash
#Script to run wifite 

cd /opt/pwnix/captures/wpa_handshakes/

wifite

if [ -d hs ]; then
  mv hs handshakes
fi

