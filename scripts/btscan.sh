#!/bin/bash
# Bluetooth scanning / logging script using hcitool

. /opt/pwnix/pwnpad-scripts/px_interface_selector.sh

#drop if after apks fixed
if $(f_validate_one hci0); then

hciconfig hci0 up
cd /opt/pwnix/captures/bluetooth/

clear
echo
echo "[-] Bluetooth scan log saved to /opt/pwnix/captures/bluetooth/"
echo

btscanlogname=hcitool$(date +%F-%H%M).log

while [ 1 ]; do
  hcitool -i hci0 scan --flush --class --info
  hcitool -i hci0 scan --flush --class --info >> /opt/pwnix/captures/bluetooth/$btscanlogname
done
#drop if after apks fixed
fi
