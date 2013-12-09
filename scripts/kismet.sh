#!/bin/bash
#Script to start Kismet wireless sniffer

##################################################
clear
echo
echo  "Kismet captures saved to /opt/pwnix/captures/wireless/"
echo
echo

wait 3

cd /opt/pwnix/captures/wireless/

kismet


