#!/bin/bash
# Script to start Kismet wireless sniffer
#set the prompt to the name of the script
PS1=${PS1//@\\h/@kismet}
clear

. /opt/pwnix/pwnpad-scripts/px_functions.sh

# Put kismet_ui.conf into position if first run
f_uicheck(){
  if [ ! -f /root/.kismet/kismet_ui.conf ]; then
    mkdir /root/.kismet
    cp /etc/kismet/kismet_ui.conf /root/.kismet/
  fi
}

# Check for BlueNMEA then start gpsd to log GPS data
f_gps_check(){

  ps ax |grep bluenmea |grep -v grep &> /dev/null
  GPS_STATUS=$?

  if [ $GPS_STATUS -eq 0 ]; then
    gpsd -n -D5 tcp://localhost:4352
  fi
}

f_cleanup(){
  f_mon_disable
  if [ $GPS_STATUS -eq 0 ]; then
    killall -9 gpsd
  fi
  f_pulse_restore
  f_endmsg
}

f_pulse_suspend(){
  EXIT_NOW=0
  if [ -e /etc/init.d/pwnix_kismet_server ]; then
    service pwnix_kismet_server status &> /dev/null
    PWNIX=$?
    if [ $PWNIX = 0 ]; then
      printf "Stopping Pwn Pulse kismet service...\n"
      service pwnix_kismet_server stop
      service pwnix_kismet_server status &> /dev/null
      if [ $PWNIX = 0 ]; then
        printf "Failed to stop kismet, please stop it manually.\n"
        EXIT_NOW=1
        return 1
      else
        RESTART_KISMET=1
      fi
    fi
  fi
  if [ -z "${RESTART_KISMET}" ]; then
    find_kismet || EXIT_NOW=1
    if [ "${EXIT_NOW}" = "0" ];then check_port || EXIT_NOW=1; fi
  fi
}

f_pulse_restore(){
  if [ "${RESTART_KISMET}" = 1 ]; then
    printf "Restarting Pwn Pulse kismet service...\n"
    service pwnix_kismet_server start
    sleep 2
    service pwnix_kismet_server status
    if [ $? = 0 ]; then
      printf "Successfully restarted Pwn Pulse kismet service.\n"
    else
      printf "Failed to restart Pwn Pulse kismet service.\n"
    fi
  fi
}

find_kismet() {
  found_kismet=$(pgrep -x kismet_server)
  if [ -n "$found_kismet" ]; then
    printf "Kismet is already running on PID $found_kismet.\n"
    printf "Would you like to cleanly restart kismet?\n"
    printf "1. Yes\n"
    printf "2. No\n\n"
    if [ "$(f_one_or_two)" = "1" ]; then
      kill -TERM $found_kismet
      sleep 2
      return 0
    else
      printf "Cannot start kismet, already running on PID $found_kismet and user let it live.\n"
      return 1
    fi
  fi
}

check_port(){
  port_2501=$(lsof -Pni 4TCP:2501 | grep :2501 | awk '{print $2}')
  if [ -n "$port_2501" ]; then
    printf "Something already bound to port 2501 with PID $port_2501\n"
    printf "Would you like kill the interferring process \"$(ps -o comm= $port_2501)\"?\n"
    printf "1. Yes\n"
    printf "2. No\n\n"
    if [ "$(f_one_or_two)" = "1" ]; then
      kill -TERM $port_2501
      sleep 2
      return 0
    else
      printf "Cannot start kismet, something is already bound to port 2501 on PID $found_kismet and user let it live.\n"
      return 1
    fi
  fi
}

f_endmsg(){
  printf  "Kismet captures saved to ${LOGDIR}\n"
  cd "${LOGDIR}" &> /dev/null
}

f_hangup(){
  f_pulse_restore
  pkill -f '/usr/bin/kismet_client'
  pkill -f '/usr/bin/kismet_server -t Kismet'
  exit 1
}

f_mon_enable
if [ "$?" = "0" ]; then
  LOGDIR="/opt/pwnix/captures/wireless/"
  cd "$LOGDIR" &> /dev/null
  if [ $? != 0 ]; then
    printf "Failed to cd into /opt/pwnix/captures/wireless, storing logs in $(pwd)\n"
    LOGDIR="$(pwd)"
  fi

  f_pulse_suspend
  if [ "${EXIT_NOW}" = 0 ]; then
    f_uicheck
    f_gps_check

    trap f_hangup INT
    trap f_hangup KILL
    trap f_hangup SIGHUP

    kismet
    f_cleanup
  fi
fi
