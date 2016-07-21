#!/bin/bash
# Run airodump-ng with no flags
#set the prompt to the name of the script
PS1=${PS1//@\\h/@airodump}
clear

. /opt/pwnix/pwnpad-scripts/px_functions.sh

f_run(){

  # Check for OUI
  f_oui
  # Check to log
  f_log
  # Check for GPS
  f_gps
  #we have a monitor interface now, so set traps to cleanup
  trap f_cleanup INT
  trap f_cleanup KILL

  STD_OPTS="-C0 --manufacturer"
  if [ $opt_log -eq 1 ]; then
    if [ $GPS_STATUS -eq 0 ]; then
      airodump-ng $STD_OPTS --gpsd -w airodump wlan1mon
    else
      airodump-ng $STD_OPTS -w airodump wlan1mon
    fi

  elif [ $opt_log -eq 2 ]; then
    if [ $GPS_STATUS -eq 0 ]; then
      airodump-ng $STD_OPTS --gpsd wlan1mon
    else
      airodump-ng $STD_OPTS wlan1mon
    fi
  fi
}

# Check for oui.txt
f_oui(){

  # Upate if not found
  if [ ! -f /etc/aircrack-ng/airodump-ng-oui.txt ]; then
    airodump-ng-oui-update &> /dev/null &
  fi
}

# Prompt user to log
f_log(){

  clear
  printf "\nSave capture to /opt/pwnix/captures/wireless/?\n\n"
  printf "1. Yes\n"
  printf "2. No\n\n"
  read -p "Choice [1 or 2]: " opt_log
  case $opt_log in
    1|2) ;;
    *) f_log;;
  esac
}

# Check for BlueNMEA to log GPS data
f_gps(){

  ps ax |grep gpsd |grep -v grep &> /dev/null
  GPSD_STATUS=$?

  if [ $GPSD_STATUS -eq 1 ]; then
    ps ax |grep bluenmea |grep -v grep &> /dev/null
    GPS_STATUS=$?

    if [ $GPS_STATUS -eq 0 ]; then
      gpsd -n -D5 tcp://localhost:4352
    fi
  fi
}

# Prompt user to keep gpsd running
f_gps_toggle(){

  printf "\n[?] Keep gpsd running?\n\n"
  printf "1. Yes\n"
  printf "2. No\n\n"
  read -p "Choice [1 or 2]: " gps
  case $gps in
    1)
      # Keep gpsd running
      printf "\n[!] gpsd is still running\n\n"
      ;;
    2)
      printf "\n[+] Stopping gpsd..\n"
      # Kill gpsd
      killall -9 gpsd &> /dev/null
      printf "\n[!] gpsd has been stopped\n\n"
      ;;
    *)f_gps_toggle ;;
  esac
}

f_cleanup(){
  f_mon_disable

  if [ $GPS_STATUS -eq 0 ]; then
    f_gps_toggle
  fi
}

f_mon_enable
if [ "$?" = "0" ]; then
  f_run
  f_cleanup
fi
