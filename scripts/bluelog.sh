#!/bin/sh
# Bluetooth scanning / logging script using bluelog

hciconfig hci0 up

cd /opt/pwnix/captures/bluetooth/

echo
echo "Bluetooth Device Scan log saved in /opt/pwnix/captures/bluetooth/"
echo

bluelog -vtnc -i hci0
