#!/bin/bash
# Run airodump-ng with no flags

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
  echo "Save capture to /opt/pwnix/captures/wireless/?"
  echo
  echo "1. Yes"
  echo "2. No"
  echo
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
    echo
    echo "[!] wlan1mon is up"
  else
    # Start if down
    echo
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

  echo
  echo "[?] Stay in monitor mode (wlan1mon)?"
  echo
  echo "1. Yes"
  echo "2. No"
  echo
  read -p "Choice [1 or 2]: " opt_mon
  case $opt_mon in
    1)
      echo
      echo "[!] wlan1mon is still up"
      echo
      ;;
    2)
      echo
      echo "[+] Bring wlan1mon down.."
      hardw=`/system/bin/getprop ro.hardware`
      if [[ "$hardw" == "deb" || "$hardw" == "flo" ]]; then
        PHY=$(cat /sys/class/net/wlan1mon/phy80211/name)
        iw dev wlan1mon del
        iw phy $PHY interface add wlan1 type station
      else
        airmon-ng stop wlan1mon &> /dev/null
      fi
      echo
      echo "[!] wlan1mon is down"
      echo
      ;;
    *)f_mon_toggle ;;
  esac

  if [ $GPS_STATUS -eq 0 ]; then
    f_gps_toggle
  fi
}

# Prompt user to keep gpsd running
f_gps_toggle(){

  echo
  echo "[?] Keep gpsd running?"
  echo
  echo "1. Yes"
  echo "2. No"
  echo
  read -p "Choice [1 or 2]: " gps
  case $gps in
    1)
      # Keep gpsd running
      echo
      echo "[!] gpsd is still running"
      echo
      ;;
    2)
      echo
      echo "[+] Stopping gpsd.."
      # Kill gpsd
      killall -9 gpsd &> /dev/null
      echo
      echo "[!] gpsd has been stopped"
      echo
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
