#!/bin/bash
#Description: Script to remove all logs and anything potentially legally binding
#Authors: Awk, Sed
#Company: Pwnie Express
#Date: March 1 2013
#Rev: 1.1

CAPTURE_FILES=(
  "/opt/pwnix/captures/*.cap"
  "/opt/pwnix/captures/*.log"
  "/opt/pwnix/captures/tshark/*"
  "/opt/pwnix/captures/tcpdump/*"
  "/opt/pwnix/captures/ettercap/*"
  "/opt/pwnix/captures/bluetooth/*"
  "/opt/pwnix/captures/stringswatch/*"
  "/opt/pwnix/captures/wireless/*"
  "/opt/pwnix/captures/nmap_scans/*"
  "/opt/pwnix/captures/wpa_handshakes/*"
  "/opt/pwnix/captures/passwords/*"
)

MISC_FILES=(
  "/opt/pwnix/easy-creds/easy-creds-*"
  "/opt/pwnix/easy-creds/*.txt"
  "/opt/pwnix/wireless/wifite/cracked.txt"
  "/opt/pwnix/wireless/wifite/hs/"
)

f_one_or_two(){
  read -p "Choice (1 or 2): " input
  case $input in
    [1-2]*) echo $input ;;
    *)
      f_one_or_two
      ;;
  esac
}

set_choosewisely(){
  echo "[+] This script will remove ALL LOGS and CAPTURES are you sure you want to continue?"
  echo
  echo " 1. Yes"
  echo " 2. No"
  choosewisely=$(f_one_or_two)
}

set_clearhistory(){
  echo "[+] Would you like to remove Bash history as well?"
  echo
  echo " 1. Yes"
  echo " 2. No"
  clearhistory=$(f_one_or_two)
}

clear_capture_files(){
  echo '[+] Removing logs and captures from /opt/pwnix/captures/'
  for file in "${CAPTURE_FILES[@]}"; do
    echo "  Removing $file"
    wipe -f -i -r $file
  done
}

clear_misc_files(){
  echo '[+] Removing miscelaneous caps and logs / handshakes from other folders'
  for file in "${MISC_FILES[@]}"; do
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
  # TODO: should this be removed?
  # clear_misc_files
  clear_tmp_files
}

clear_bash_history(){
  echo '[+] Clearing bash history...'
  rm -r /root/.bash_history
  rm -r /home/pwnie/.bash_history
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
      echo "[+] Congratulations all your logs, captures, and bash history have been cleared!"
      echo "[+] Unless of course you forgot about something else this script didn't know about..."
    else
      clear
      echo "[-] Skipping clearing bash history today"
      echo "[+] Congratulations all your logs and captures have been cleared!"
      echo "[+] Unless of course you forgot about something else this script didn't know about..."
    fi

  else
    clear
    echo "[+] Your logs, captures, and bash history have been left alone."
    echo "[+] Have a nice day ^_^"
  fi
}

f_initialize
