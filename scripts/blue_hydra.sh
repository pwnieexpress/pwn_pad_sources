#!/bin/bash
# Bluetooth scanning / logging script using bluelog
#set the prompt to the name of the script
PS1=${PS1//@\\h/@blue_hydra}
clear

bluetooth=1
. /opt/pwnix/pwnpad-scripts/px_functions.sh

if loud_one=1 f_validate_one hci0; then
  hciconfig hci0 up
  cd /opt/pwnix/blue_hydra/
  service dbus status || service dbus start
  service bluetooth status || service bluetooth start
  clear
  ./bin/blue_hydra
  cd /opt/pwnix/captures/bluetooth
  clear
  printf "\n[-] Blue_Hydra db file saved to /opt/pwnix/blue_hydra.db\n\n"
fi
