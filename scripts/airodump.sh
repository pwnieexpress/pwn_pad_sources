#!/bin/bash
# Run airodump-ng with no flags
clear

. /opt/pwnix/pwnpad-scripts/px_functions.sh

if quiet_one=1 f_validate_one wlan1mon; then
  interface=wlan1mon
elif f_validate_one wlan1; then
  interface=wlan1
fi

if [ -n "$interface" ]; then

f_run(){

  # Check for OUI
  f_oui
  # Check to log
  f_log
  # Check for wlan1mon
  f_mon
  # Check for GPS
  f_gps

  if [ $opt_log -eq 1 ]; then
    if [ $GPS_STATUS -eq 0 ]; then
      airodump-ng --manufacturer --gpsd -w airodump wlan1mon
    else
      airodump-ng --manufacturer -w airodump wlan1mon
    fi

  elif [ $opt_log -eq 2 ]; then
    if [ $GPS_STATUS -eq 0 ]; then
      airodump-ng --manufacturer --gpsd wlan1mon
    else
      airodump-ng --manufacturer wlan1mon
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
    [1-2]*) ;;
    *) f_log;;
  esac
}

# Check for monitor mode
f_mon(){

  ifconfig -a |grep mon &> /dev/null
  MON_STATUS=$?

  if [ $MON_STATUS -eq 0 ]
  then
    printf "\n[!] wlan1mon is up\n"
  else
    # Start if down
    printf "\n"
    airmon-ng start wlan1
  fi
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

# Prompt user to keep wlan1mon up
f_mon_toggle(){

  printf "\n[?] Stay in monitor mode (wlan1mon)?\n\n"
  printf "1. Yes\n"
  printf "2. No\n\n"
  read -p "Choice [1 or 2]: " opt_mon
  case $opt_mon in
    1)
      printf "\n[!] wlan1mon is still up\n\n"
      ;;
    2)
      printf "\n[+] Bring wlan1mon down..\n"
      hardw=`/system/bin/getprop ro.hardware`
      if [[ "$hardw" == "deb" || "$hardw" == "flo" ]]; then
        PHY=$(cat /sys/class/net/wlan1mon/phy80211/name)
        iw dev wlan1mon del
        iw phy $PHY interface add wlan1 type station
      else
        airmon-ng stop wlan1mon &> /dev/null
      fi
      printf "\n[!] wlan1mon is down\n\n"
      ;;
    *)f_mon_toggle ;;
  esac

  if [ $GPS_STATUS -eq 0 ]; then
    f_gps_toggle
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

  # Prompt user for monitor mode
  f_mon_toggle
  # Bring wlan1 down
  ifconfig wlan1 down &> /dev/null
}

f_run
f_cleanup
fi
