#!/bin/bash
# Bluetooth scanning / logging script using bluelog
# Set the prompt to the name of the script
PS1=${PS1//@\\h/@bluelog}
clear

# Cleanup 
f_hangup(){
  pkill -f 'bluelog -vtnc -i hci0'
  trap - SIGHUP
  exit 0
}

bluetooth=1
. /opt/pwnix/pwnpad-scripts/px_functions.sh

if loud_one=1 f_validate_one hci0; then

hciconfig hci0 up
cd /opt/pwnix/captures/bluetooth/

clear
printf "\n[-] Bluelog scan log saved to /opt/pwnix/captures/bluetooth/\n\n"

# Set traps to cleanup
trap f_hangup SIGHUP

bluelog -vtnc -i hci0
fi
