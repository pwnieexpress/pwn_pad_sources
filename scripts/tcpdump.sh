#!/bin/bash
#tcpdump init script

/etc/init.d/ssh start
modprobe ath9k_htc
ssh -t root@localhost "cd /opt/pwnpad/captures/ ; sh /opt/pwnpad/scripts/tcpdump1.sh ; bash"
