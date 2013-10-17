#!/bin/bash

/etc/init.d/ssh start
modprobe ath9k_htc
ssh -t root@localhost "cd /opt/pwnpad/ ; sh /opt/pwnpad/scripts/hostmacchanger1.sh ; bash"
