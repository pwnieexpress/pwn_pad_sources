#!/bin/bash
# Cleartext password sniffing on all available interfaces


f_identify_device(){
  
  # Check device
  hardw=`getprop ro.hardware`
  if [[ "$hardw" == "deb" || "$hardw" == "flo" ]]; then
    # Set interface for new Pwn Pad
    gsm_int="rmnet_usb0"
  else
    # Set interface for Pwn Phone and old Pwn Pad
    gsm_int="rmnet0"
  fi
}
  
f_interface_setup(){
  clear
  echo "Select which interface to sniff on [1-6]:"
  echo
  echo "1. eth0 (USB Ethernet adapter)"
  echo "2. wlan0 (internal Wifi)"
  echo "3. wlan1 (USB TP-Link adapter)"
  echo "4. mon0 (monitor mode interface)"
  echo "5. at0 (Use with EvilAP)"
  echo "6. $gsm_int (4G GSM connection)"
  echo

  read -p "Choice: " interfacechoice

  case $interfacechoice in
    1) interface=eth0 ;;
    2) interface=wlan0 ;;
    3) interface=wlan1 ;;
    4) interface=mon0 ;;
    5) interface=at0 ;;
    6) interface=$gsm_int ;;
    *) f_interface_setup ;;
  esac
}

f_logging_setup(){
  clear
  echo
  echo "Would you like to log data?"
  echo
  echo "Captures saved to /opt/pwnix/captures/passwords/"
  echo
  echo "1. Yes"
  echo "2. No "
  echo
  f_get_logchoice
}

f_get_logchoice(){
  read -p "Choice: " logchoice
  case $logchoice in
    [1-2]*) ;;
    *)
      echo 'Please enter 1 for YES or 2 for NO.'
      f_get_logchoice
      ;;
  esac
}

f_run(){
  # If user chose to log, log to folder
  # else just run cmd
  if [ $logchoice -eq 1 ]; then
    filename=/opt/pwnix/captures/passwords/dsniff_$(date +%F-%H%M).log
    ettercap -i $interface -u -T -q | tee $filename
  elif [ $logchoice -eq 2 ]; then
    ettercap -i $interface -T -q -u
  fi
}

f_execute(){
  f_identify_device
  f_interface_setup
  f_logging_setup
  f_run
}

f_execute
