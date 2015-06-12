#!/bin/bash
# Bluetooth scanning / logging script using bluelog
clear

. /opt/pwnix/pwnpad-scripts/px_interface_selector.sh

#drop if after apks fixed
if f_validate_one hci0; then

hciconfig hci0 up
cd /opt/pwnix/captures/bluetooth/

clear
echo
echo "[-] Bluelog scan log saved to /opt/pwnix/captures/bluetooth/"
echo

bluelog -vtnc -i hci0
#drop if after apks fixed
fi
