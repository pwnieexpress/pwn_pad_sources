#!/bin/sh
# Bluetooth scanning / logging script using bluelog

. /opt/pwnix/pwnpad-scripts/px_interface_selector.sh

f_validate_one hci0

hciconfig hci0 up
cd /opt/pwnix/captures/bluetooth/

clear
echo
echo "[-] Bluelog scan log saved to /opt/pwnix/captures/bluetooth/"
echo

bluelog -vtnc -i hci0
