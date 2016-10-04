#!/bin/bash
# Bluetooth scanning / logging script using bluelog
#set the prompt to the name of the script
PS1=${PS1//@\\h/@bluelog}
clear

#cleanup running processes
f_hangup(){
  pkill -f 'bluelog -vtnc -i hci0'
  exit 1
}

bluetooth=1
. /opt/pwnix/pwnpad-scripts/px_functions.sh

if loud_one=1 f_validate_one hci0; then

hciconfig hci0 up
cd /opt/pwnix/captures/bluetooth/

clear
printf "\n[-] Bluelog scan log saved to /opt/pwnix/captures/bluetooth/\n\n"

#set traps to cleanup
trap f_hangup SIGHUP

bluelog -vtnc -i hci0
fi
