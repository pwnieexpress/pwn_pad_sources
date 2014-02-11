#!/bin/bash
# Description: Script to remove all logs and anything potentially legally binding
# Authors: Awk, Sed
# Company: Pwnie Express
# Date: January 23 2014
# Rev: 1.1

CAPTURE_FILES=$(find /opt/pwnix/captures -type f)

f_one_or_two(){
  read -p "Choice (1-2): " input
  case $input in
    [1-2]*) echo $input ;;
    *)
      f_one_or_two
      ;;
  esac
}

set_choosewisely(){
  echo
  echo "[+] This script will remove ALL LOGS and CAPTURES are you sure you want to continue?"
  echo
  echo " 1. Yes"
  echo " 2. No"
  echo
  choosewisely=$(f_one_or_two)
}

set_clearhistory(){
  echo
  echo "[+] Would you like to remove Bash history as well?"
  echo
  echo " 1. Yes"
  echo " 2. No"
  echo
  clearhistory=$(f_one_or_two)
}

clear_capture_files(){
  echo "[+] Removing logs and captures from /opt/pwnix/captures/"
  for file in "${CAPTURE_FILES[@]}"; do
    echo "  Removing $file"
    wipe -f -i -r $file
  done
}

clear_tmp_files(){
  echo '[+] Removing all files from /tmp/'
  wipe -f -i -r /tmp/*
}

clear_all_files(){
  clear_capture_files
  clear_tmp_files
}

clear_bash_history(){
  echo '[+] Clearing bash history...'
  rm -r /root/.bash_history
  rm -r /home/pwnie/.bash_history
  history -c
}

f_initialize(){
  clear
  set_choosewisely
  set_clearhistory

  if [ $choosewisely -eq 1 ]; then
    clear
    clear_all_files

    if [ $clearhistory -eq 1 ]; then
      clear_bash_history
      clear
      echo
      echo
      echo "[+] Congratulations all your logs, captures, and bash history have been cleared!"
      echo "[+] Unless of course you forgot about something else this script didn't know about..."
    else
      clear
      echo
      echo
      echo "[-] Skipping clearing bash history today"
      echo "[+] Congratulations all your logs and captures have been cleared!"
      echo "[+] Unless of course you forgot about something else this script didn't know about..."
    fi
  else

      clear

      if [ $clearhistory -eq 1 ]; then
        echo
        echo "[+] Bash history cleared"
        echo
        echo "[+] Logs and Captures have been left alone."
        echo "[+] Have a nice day ^_^"
      else 
        echo
        echo
        echo "[+] Your logs, captures, and bash history have been left alone."
        echo "[+] Have a nice day ^_^"
      fi
  fi
  echo
  echo
}

f_initialize
