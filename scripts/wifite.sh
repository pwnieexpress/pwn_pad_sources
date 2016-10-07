#!/bin/bash
# Script to run Wifite
# Set the prompt to the name of the script
PS1=${PS1//@\\h/@wifite}
clear

. /opt/pwnix/pwnpad-scripts/px_functions.sh

f_mon_enable
if [ "$?" = "0" ]; then
  cd /opt/pwnix/captures/wpa_handshakes/

  clear
  # Wifite currently cannot put a device in monitor mode,
  # however, it seems to cleanly handle if a device is already
  # new airmon-ng won't make duplicate interfaces, so run it just to make sure we have a monitor.
  wifite
  trap '' INT
  f_mon_disable
  trap - INT
  if [ -d hs ]; then
    mv hs/* .
    rm -r hs/
  fi

  if [ -f cracked.txt ]
  then
    mv cracked.txt ../passwords/
  fi
fi
