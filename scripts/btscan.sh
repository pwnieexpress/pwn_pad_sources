#!/bin/sh
# Bluetooth scanning / logging script using hcitool


cd /opt/pwnix/captures/bluetooth/

hciconfig hci0 up

echo
echo "Bluetooth Device Scan log saved in /opt/pwnix/captures/bluetooth/"
echo

btscanlogname=hcitool$(date +%F-%H%M).log

while [ 1 ]
do
	hcitool -i hci0 scan --flush --class --info
  hcitool -i hci0 scan --flush --class --info >> /opt/pwnix/captures/bluetooth/$btscanlogname
done
