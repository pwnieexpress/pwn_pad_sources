#!/bin/sh
#unified f_interface function abstract
#usage:   px_interface_selector.sh <cell allowed> [default selection]
#example: px_interface_selector.sh 1 wlan1mon
#           cell allowed, default to wlan1mon
#TODO: actually handle default interface

f_identify_device(){
# Check device
  if command -v /system/bin/getprop > /dev/zero 2>&1; then
    hardw=`/system/bin/getprop ro.hardware`
    if [[ "$hardw" == "deb" || "$hardw" == "flo" ]]; then
      # Set interface for new Pwn Pad
      gsm_int="rmnet_usb0"
    else
      # Set interface for Pwn Phone and old Pwn Pad
      gsm_int="rmnet0"
    fi
  else
    #we don't have access to /system/bin/getprop, use sane default
    gsm_int="rmnet0"
  fi
}

f_interface(){
  cell_enabled=${1:-0}
  if [ "$cell_enabled" = "1" ]; then
    f_identify_device
  fi
  clear
  printf "Select which interface to sniff on [1-6]:\n"
  printf "\n"
  printf "$(f_colorize eth0)1. eth0  (USB Ethernet adapter)\e[0m\n"
  printf "$(f_colorize wlan0)2. wlan0  (internal Wifi)\e[0m\n"
  printf "$(f_colorize wlan1)3. wlan1  (USB TP-Link adapter)\e[0m\n"
  printf "$(f_colorize wlan1mon)4. wlan1mon  (monitor mode interface)\e[0m\n"
  printf "$(f_colorize at0)5. at0  (Use with EvilAP)\e[0m\n"
  [ "$cell_enabled" = "1" ] && printf "$(f_colorize $gsm_int)6. $gsm_int (4G GSM connection)\e[0m\n"
  printf "\n"
  printf "NOTE: If selected interface is unavailable, this menu will loop.\n"
  read -p "Choice: " interfacechoice

  case $interfacechoice in
    1) interface=eth0 ;;
    2) interface=wlan0 ;;
    3) interface=wlan1 ;;
    4) interface=wlan1mon ;;
    5) interface=at0 ;;
    6) interface=$gsm_int ;;
    0) f_interface 1 $2 ;;
    *) f_interface $cell_enabled $2;;
  esac
  ifconfig $interface >/dev/zero 2>&1 || f_interface $cell_enabled $2
}

f_colorize(){
  ifconfig $1 > /dev/zero 2>&1
  if [ $? = 0 ]; then
    #greeen text for exists
    printf "\e[1;32m"
  elif  [ $? = 1 ]; then
    #red text for does not exist
    printf "\e[1;31m"
  else
    #blue on unknown
    printf "\e[1;34m"
  fi
}

#f_interface $1 $2
#printf "interface=$interface\n"
