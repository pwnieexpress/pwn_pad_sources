#!/bin/bash
#Description: Script to watch strings from packets go by in real time
#Author: Awk, Sed
#Company: Pwnie Express
#Date: Jan 22 2014
#Rev: 1.0

f_identify_device(){
  # Function to determine whether current device is new pad or old pad
  # Checking to see if this is the old pad or the new pad:
  cat /proc/cpuinfo |grep grouper &> /dev/null
  pad_old_or_new=`echo $?`
  
  # If pad_old_or_new = 1 then current device is New Pad
  if [ $pad_old_or_new -eq 1 ]; then

    # New Pad's GSM interface is rmnet_usb0
    gsm_int="rmnet_usb0"
    else
    # Old Pad's GSM interface is rmnet0
    gsm_int="rmnet0"
  fi
}

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
  echo "6. $gsm_int (Internal 4G GSM)"
  echo

  read -p "Choice (1-6): " interfacechoice

  case $interfacechoice in
    1) interface=eth0 ;;
    2) interface=wlan0 ;;
    3) interface=wlan1 ;;
    4) interface=mon0 ;;
    5) interface=at0 ;;
    6) interface=$gsm_int ;;
    *) f_interface ;;
  esac
}

f_savecap(){
  clear

  echo
  echo
  echo "Would you like to save a strings log to /opt/pwnix/captures/stringswatch/ ?"
  echo
  echo "1. Yes"
  echo "2. No"
  echo

  read -p "Choice (1-2): " saveyesno

  case $saveyesno in
    1) f_yes ;;
    2) f_no ;;
    *) f_savecap ;;
  esac
}

f_yes(){
	filename=/opt/pwnix/captures/stringswatch/strings$(date +%F-%H%M).log
	tshark -i $interface -q -w - | strings -n 8 | tee $filename
}

f_no(){
	tshark -i $interface -q -w - | strings -n 8
}

f_identify_device
f_interface
f_savecap
