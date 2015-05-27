#!/bin/sh
#unified f_interface function abstract
# variables consumed:
#  cell_enabled - enable or disable $gsm_int
#  all_wifi - enable or disable wlan1mon and at0
#  include_monitor - enable or disable wlan1mon
#  default_interface - contains default interface, if any
#TODO: handle default interface

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
  : ${all_wifi:=-1}
  : ${cell_enabled:=0}
  : ${include_monitor:=1}
  if [ "$cell_enabled" = "1" ]; then
    f_identify_device
  fi
  clear
  printf "Select which interface to sniff on [1-6]:\n"
  printf "\n"
  printf "$(f_colorize eth0)1. eth0  (USB Ethernet adapter)$(f_isdefault eth0)\e[0m\n"
  printf "$(f_colorize wlan0)2. wlan0  (internal Wifi)$(f_isdefault wlan0)\e[0m\n"
  printf "$(f_colorize wlan1)3. wlan1  (USB TP-Link adapter)$(f_isdefault wlan1)\e[0m\n"
  [ "$all_wifi" = "1" ] || [ "$include_monitor" = "1" ] && printf "$(f_colorize wlan1mon)4. wlan1mon  (monitor mode interface)$(f_isdefault wlan1mon)\e[0m\n"
  [ "$all_wifi" = "1" ] && printf "$(f_colorize at0)5. at0  (Use with EvilAP)$(f_isdefault at0)\e[0m\n"
  [ "$cell_enabled" = "1" ] && printf "$(f_colorize $gsm_int)6. $gsm_int (4G GSM connection)$(f_isdefault $gsm_int)\e[0m\n"
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
    0) cell_enabled=1 all_wifi=1 f_interface  ;;
    *) interface=${default_interface} ;;
  esac
  ifconfig $interface >/dev/zero 2>&1 || f_interface $cell_enabled $all_wifi
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

f_isdefault(){
  if [ "$default_interface" = "$1" ]; then
    printf " (default)"
  fi
}

f_interface
printf "interface=$interface\n"
