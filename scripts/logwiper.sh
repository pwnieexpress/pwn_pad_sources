#!/bin/bash
# Description: Script to remove all logs and anything potentially legally binding
# Authors: Awk, Sed, t1mz0r
# Company: Pwnie Express
# Date: May 2014

CAPTURE_FILES=$(find /opt/pwnix/captures -type f)

f_one_or_two(){
  read -p "Choice [1-2]: " input
  case $input in
    [1-2]*) echo $input ;;
    *)
      f_one_or_two
      ;;
  esac
}

set_choosewisely(){
  echo
  echo "[!] This will remove ALL LOGS and CAPTURES!"
  echo 
  echo "[?] Are you sure you want to continue?"
  echo
  echo " 1. Yes"
  echo " 2. No"
  echo
  choosewisely=$(f_one_or_two)
}

set_clearhistory(){
  echo
  echo "[?] Would you like to remove Bash history as well?"
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
      echo "[!] All logs, captures, and bash history have been cleared!"
      echo "[-] Unless of course you hid something..."
    else
      clear
      echo
      echo "[-] Skipping bash history clear"
      echo "[!] All logs and captures have been cleared!"
      echo "[-] Unless of course you hid something..."
    fi
  else

    clear
    if [ $clearhistory -eq 1 ]; then
      echo
      echo "[+] Bash history has been cleared!"
      echo
      echo "[+] Logs and captures have been left alone"
      echo "[!] Pwnies run wild!"
    else 
      echo
      echo "[+] All logs, captures, and bash history have been left alone"
      echo "[!] Have a nice day! ^_^"
    fi
  fi
  echo
}

f_initialize
