#!/bin/bash
# Bluetooth scanning / logging script using bluelog
clear

bluetooth=1
. /opt/pwnix/pwnpad-scripts/px_functions.sh

if loud_one=1 f_validate_one hci0; then

hciconfig hci0 up
cd /opt/pwnix/captures/bluetooth/

clear
printf "\n[-] Bluelog scan log saved to /opt/pwnix/captures/bluetooth/\n\n"

bluelog -vtnc -i hci0
fi
