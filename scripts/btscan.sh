#!/bin/bash
# Bluetooth scanning / logging script using hcitool
#set the prompt to the name of the script
PS1=${PS1//@\\h/@btscan}
clear

bluetooth=1
. /opt/pwnix/pwnpad-scripts/px_functions.sh

if loud_one=1 f_validate_one hci0; then

hciconfig hci0 up
cd /opt/pwnix/captures/bluetooth/

clear
printf "\n[-] Bluetooth scan log saved to /opt/pwnix/captures/bluetooth/\n\n"

btscanlogname=hcitool$(date +%F-%H%M).log

while [ 1 ]; do
  hcitool -i hci0 scan --flush --class --info | tee -a /opt/pwnix/captures/bluetooth/$btscanlogname
done
fi
