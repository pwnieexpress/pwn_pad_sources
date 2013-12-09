#!/bin/sh
#Bluetooth scanning / loggin script

hciconfig hci0 up

cd /opt/pwnix/captures/bluetooth/

echo
echo "Bluetooth Device Scan log saved in /opt/pwnix/captures/bluetooth/"
echo

#btscanlogname=bluelog$(date +%F-%H%M).log

bluelog -vtnc -i hci0

