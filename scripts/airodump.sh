#!/bin/bash
# Script to run airodump-ng without any flags

# set ctrl c (break) to gracefully take the card out of monitor mode
trap f_cleanup INT
trap f_cleanup KILL

cd /opt/pwnix/captures/wireless/

f_capture_dialogue(){
	clear
	echo
	echo "Would you like to save an Airodump capture?"
	echo
	echo "Captures saved to /opt/pwnix/captures/wireless/"
	echo
	echo "1. Yes"
	echo "2. No "
	echo
}

f_logchoice(){
  read -p "Choice (1 or 2): " logchoice
  case $logchoice in
    [1-2]*) ;;
    *) f_logchoice;;
  esac
}

f_run(){
  if [ $logchoice -eq 1 ]; then
    airmon-ng start wlan1
    airodump-ng -w airodump mon0
  elif [ $logchoice -eq 2 ]; then
    airmon-ng start wlan1
    airodump-ng mon0
  fi
}

f_mon_up_down(){
  echo
  echo "[!] Do you want to stay in monitor mode (mon0)?"
  echo
  read -p "Choice (1 or 2): " opt
  case $opt in
    1)
      # do nothing
      echo "[+] mon0 still active"
      ;;
    2)
      echo "[+] Stopping mon0.."
      airmon-ng stop mon0
      ;;
    *) f_one_or_two;;
  esac
}

f_cleanup(){
  f_mon_up_down

  # ... and stay down!
  ifconfig wlan1 down
}

f_capture_dialogue
f_logchoice
f_run
