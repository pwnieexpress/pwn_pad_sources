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
  "/opt/pwnix/captures/sslstrip/*"
  "/opt/pwnix/captures/bluetooth/*"
  "/opt/pwnix/captures/stringswatch/*"
  "/opt/pwnix/captures/evilap/*"
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

set_choosewisely(){
  echo '
  This script will remove ALL LOGS and CAPTURES are you sure you want to continue?

  1. Yes
  2. No

  '
  read -p "Choice: " choosewisely
}

set_clearhistory(){
  echo '
  Would you like to remove Bash history as well?

  1. Yes
  2. No

  '
  read -p "Choice: " clearhistory
}

clear_capture_files(){
  echo 'Removing logs and captures from /opt/pwnix/captures/

  '
  for file in "${CAPTURE_FILES[@]}"
  do
    echo "  Removing $file"
    wipe -f -i -r $file
  done
}

clear_misc_files(){
  echo 'Removing miscelaneous caps and logs / handshakes from other folders

  '
  for file in "${MISC_FILES[@]}"
  do
    echo "  Removing $file"
    wipe -f -i -r $file
  done
}

clear_tmp_files(){
  echo 'Removing all files from /tmp/

  '
  wipe -f -i -r /tmp/*
}

clear_all_files(){
  clear_capture_files
# clear_misc_files
  clear_tmp_files
}

clear_bash_history(){
                echo '
      Clearing bash history...
    '
               rm -r /root/.bash_history
               rm -r /home/pwnie/.bash_history
}

initialize(){
  clear
  set_choosewisely
  set_clearhistory

  if [ $choosewisely -eq 1 ]
   then
    clear

    clear_all_files

    if [ $clearhistory -eq 1 ]
     then    
      clear_bash_history
      clear
      echo "
  
        Congratulations all your logs, captures, and bash history have been cleared!
  
   Unless of course you forgot about something else this script didn't know about...
       "

     else

      clear
      echo "
                      Not clearing bash history today
                
            Congratulations all your logs and captures have been cleared!
                
    Unless of course you forgot about something else this script didn't know about...
               "
     fi

  else
    clear
    echo "
     Your logs, captures, and bash history have been left alone.
     Have a nice day ^_^
    "
  fi
}

initialize
