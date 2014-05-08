#!/bin/sh
# Bluetooth scanning / logging script using bluelog

hciconfig hci0 up
cd /opt/pwnix/captures/bluetooth/

clear
echo
echo "[-] Bluelog scan log saved to /opt/pwnix/captures/bluetooth/"
echo

bluelog -vtnc -i hci0
