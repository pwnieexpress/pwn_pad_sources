#!/bin/sh
#Bluetooth scanning / loggin script

f_modprobe(){
#load all modules for external adapters:
mkdir -p /dev/net/
ln -s /dev/tun /dev/net/tun
modprobe ath9k_htc
modprobe btusb
modprobe tun
}

f_modprobe

hciconfig hci0 up

echo
echo "Bluetooth Device Scan log saved in /opt/pwnpad/captures/bluetooth/"
echo

btscanlogname=hcitool$(date +%F-%H%M).log

while [ 1 ]
do
	hcitool -i hci0 scan --flush --class --info

        hcitool -i hci0 scan --flush --class --info >> /opt/pwnpad/captures/bluetooth/$btscanlogname

done
