#!/bin/bash
#Description: Script to watch strings from packets go by in real time
#Author: Awk
#Company: Pwnie Express
#Date: Feb 2013
#Rev: 1.0


##################################################
f_modprobe(){
#load all modules for external adapters:
mkdir -p /dev/net/
ln -s /dev/tun /dev/net/tun
modprobe ath9k_htc
modprobe btusb
modprobe tun
}

f_modprobe


##################################################
f_interface(){
        clear

echo 
echo 
echo "Select which interface you would like to sniff on? (1-6):"
echo 
echo "1. eth0  (USB ethernet adapter)"
echo "2. wlan0  (Internal Nexus Wifi)"
echo "3. wlan1  (USB TPlink Atheros)"
echo "4. mon0  (monitor mode interface)"
echo "5. at0  (Use with EvilAP)"
echo "6. rmnet0 (Internal 3G GSM)"
echo

        read -p "Choice: " interfacechoice

        case $interfacechoice in
        1) f_eth0 ;;
        2) f_wlan0 ;;
        3) f_wlan1 ;;
        4) f_mon0 ;;
        5) f_at0 ;;
	6) f_rmnet0 ;;
        *) f_interface ;;
        esac
}

#########################################
f_eth0(){
	interface=eth0
}

#########################################
f_wlan0(){
        interface=wlan0
}


#########################################
f_wlan1(){
        interface=wlan1
}


#########################################
f_mon0(){
        interface=mon0
}


#########################################
f_at0(){
        interface=at0
}

#########################################
f_rmnet0(){
        interface=rmnet0
}


#########################################
f_savecap(){
        clear

echo 
echo 
echo "Would you like to save a strings log to /opt/pwnpad/captures/stringswatch/ ?"
echo
echo "1. Yes"
echo "2. No"
echo

        read -p "Choice: " saveyesno

        case $saveyesno in
        1) f_yes ;;
        2) f_no ;;
        *) f_savecap ;;
        esac
}

#########################################
f_yes(){
	filename=/opt/pwnpad/captures/stringswatch/strings$(date +%F-%H%M).log

	tshark -i $interface -q -w - | strings -n 8 | tee $filename
}

#########################################
f_no(){

	tshark -i $interface -q -w - | strings -n 8
}

f_interface

f_savecap
