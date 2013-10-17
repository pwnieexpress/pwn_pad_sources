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

#cd /opt/pwnpad/captures/bluetooth/

#echo
#echo "Bluetooth Device Scan log saved in /opt/pwnpad/captures/bluetooth/bluelog"
#echo

#btscanlogname=bluelog$(date +%F-%H%M).log

ssh -t root@localhost "cd /opt/pwnpad/captures/bluetooth/ ; clear ; echo "Bluetooth Device Scan log saved in /opt/pwnpad/captures/bluetooth/" ; echo "" ; bluelog -vtnc -i hci0 ; bash"

#cd /opt/pwnpad/captures/bluetooth/
