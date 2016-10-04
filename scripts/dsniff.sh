#!/bin/bash
# Cleartext password sniffing on all available interfaces
#set the prompt to the name of the script
PS1=${PS1//@\\h/@dsniff}
clear

#this block controls the features for px_interface_selector
include_all=1
. /opt/pwnix/pwnpad-scripts/px_functions.sh

f_logging_setup(){
  printf "\nWould you like to log data?\n\n"
  printf "Captures saved to /opt/pwnix/captures/passwords/\n\n"
  printf "1. Yes\n"
  printf "2. No\n\n"
  f_get_logchoice
}

f_get_logchoice(){
  read -p "Choice: " logchoice
  case $logchoice in
    1|2) ;;
    *)
      printf 'Please enter 1 for YES or 2 for NO.\n'
      f_get_logchoice
      ;;
  esac
}

f_run(){
  #ettercap fails if the interface is down
  ip link set $interface up

  trap f_hangup SIGHUP

  # If user chose to log, log to folder
  # else just run cmd
  if [ $logchoice -eq 1 ]; then
    filename=/opt/pwnix/captures/passwords/dsniff_$(date +%F-%H%M).log
    ettercap -i $interface -u -T -q | tee $filename
  elif [ $logchoice -eq 2 ]; then
    ettercap -i $interface -T -q -u
  fi
}

f_hangup(){
  pkill -f 'ettercap -i wlan0 -T -q -u'
  exit 1
}

f_interface
f_logging_setup
f_run
