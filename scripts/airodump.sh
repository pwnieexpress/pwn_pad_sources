#!/bin/bash
# Script to run airodump-ng without any flags

cd /opt/pwnix/captures/wireless/

f_oui_check(){
  # Update oui.txt in background if oui.txt not found
  if [ ! -f /etc/aircrack-ng/airodump-ng-oui.txt ]; then
    airodump-ng-oui-update &> /dev/null &
  fi
}

f_logging(){
  clear
  echo
  echo "Would you like to save an Airodump capture?"
  echo
  echo "Captures saved to /opt/pwnix/captures/wireless/"
  echo
  echo "1. Yes"
  echo "2. No "
  echo
  read -p "Choice (1 or 2): " logchoice
  case $logchoice in
    [1-2]*) ;;
    *) f_logging;;
  esac
}

# Function to check for BlueNMEA and start GPSD if present for GPS logging
# Function first checks to see if GPSD is already running as well
f_gps_check(){

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

f_airodump(){

  #check to see if mon0 active
  f_check_mon

  if [ $logchoice -eq 1 ]; then
    if [ $GPS_STATUS -eq 0 ]; then
      airodump-ng --manufacturer --gpsd -w airodump mon0
    else
    airodump-ng --manufacturer -w airodump mon0
    fi

  elif [ $logchoice -eq 2 ]; then
    if [ $GPS_STATUS -eq 0 ]; then
      airodump-ng --manufacturer --gpsd mon0
    else
    airodump-ng --manufacturer mon0
    fi
  fi
}

f_mon_up_down(){
  echo
  echo "[!] Do you want to stay in monitor mode (mon0)?"
  echo
  echo "1. Yes"
  echo "2. No"
  echo
  read -p "Choice (1 or 2): " opt
  case $opt in
    1)
      # do nothing
      echo
      echo "[+] mon0 still active"
      echo
      ;;
    2)
      echo
      echo "[+] Stopping mon0.."
      echo
      airmon-ng stop mon0
      echo
      ;;
    *)f_mon_up_down ;;
  esac

  if [ $GPS_STATUS -eq 0 ]; then
    f_gps_up_down
  fi
}

f_gps_up_down(){

  echo
  echo "[!] Do you want to keep gpsd running?"
  echo
  echo "1. Yes"
  echo "2. No"
  echo
  read -p "Choice (1 or 2): " gps
  case $gps in
    1)
      # do nothing
      echo
      echo "[+] gpsd still running"
      echo
      ;;
    2)
      echo
      echo "[+] Killing gpsd.."
      echo
      # stop any instances of gpsd
      killall -9 gpsd &> /dev/null
      echo
      ;;
    *)f_gps_up_down ;;
  esac
}

f_cleanup(){
  f_mon_up_down

  # ... and stay down!
  ifconfig wlan1 down
}

f_check_mon(){

 ifconfig -a |grep mon &> /dev/null
 MON_STATUS=$?

 if [ $MON_STATUS -eq 0 ]
 then
   echo
   echo "[+] mon0 already active"
   echo
 else
   airmon-ng start wlan1
 fi
}

f_oui_check
f_logging
f_gps_check
f_airodump
f_cleanup
