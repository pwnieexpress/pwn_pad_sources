#!/bin/bash
#Tshark init script

/etc/init.d/ssh start
modprobe ath9k_htc
ssh -t root@localhost "cd /opt/pwnpad/captures/tshark/ ; sh /opt/pwnpad/scripts/tshark1.sh ; bash"
