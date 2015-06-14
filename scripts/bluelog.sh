#!/bin/bash
# Bluetooth scanning / logging script using bluelog
clear

bluetooth=1
. /opt/pwnix/pwnpad-scripts/px_interface_selector.sh

if f_validate_one hci0; then

hciconfig hci0 up
cd /opt/pwnix/captures/bluetooth/

clear
printf "\n[-] Bluelog scan log saved to /opt/pwnix/captures/bluetooth/\n\n"

bluelog -vtnc -i hci0
fi
