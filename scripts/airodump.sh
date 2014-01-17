#!/bin/bash
#Script to run airodump-ng without any flags

#set ctrl c (break) to gracefully take the card out of monitor mode
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
  f_validate
}

f_validate(){
	read -p "Choice: " logchoice
  if [ $logchoice = 1 -o $logchoice = 2 ]; then
    f_run $logchoice
  else
    echo 'Please enter 1 for yes or 2 for no.'
    f_validate
	fi
}

f_run(){
  if [ $1 -eq 1 ]; then
    airmon-ng start wlan1
    airodump-ng -w airodump mon0
  elif [ $1 -eq 2 ]; then
    airmon-ng start wlan1
    airodump-ng mon0
  fi
}

f_cleanup(){
  airmon-ng stop mon0
  ifconfig wlan1 down
}

f_capture_dialogue
