#!/bin/bash
# Description: Script to remove all logs and anything potentially legally binding
clear

CAPTURE_FILES=$(find /opt/pwnix/captures -type f)

f_one_or_two(){
  read -p "Choice [1-2]: " input
  case $input in
    [1-2]*) printf "$input\n" ;;
    *)
      f_one_or_two
      ;;
  esac
}

set_choosewisely(){
  printf "\n[!] This will remove ALL LOGS and CAPTURES!\n\n"
  printf "[?] Are you sure you want to continue?\n\n"
  printf " 1. Yes\n"
  printf " 2. No\n\n"
  choosewisely=$(f_one_or_two)
}

set_clearhistory(){
  printf "\n[?] Would you like to remove Bash history as well?\n\n"
  printf " 1. Yes\n"
  printf " 2. No\n\n"
  clearhistory=$(f_one_or_two)
}

clear_capture_files(){
  printf "[+] Removing logs and captures from /opt/pwnix/captures/\n"
  for file in "${CAPTURE_FILES[@]}"; do
    printf "  Removing $file\n"
    wipe -f -i -r $file
  done
}

clear_tmp_files(){
  printf '[+] Removing all files from /tmp/\n'
  wipe -f -i -r /tmp/*
}

clear_all_files(){
  clear_capture_files
  clear_tmp_files
}

clear_bash_history(){
  printf '[+] Clearing bash history...\n'
  rm -r /root/.bash_history
  rm -r /home/pwnie/.bash_history
  history -c
}

f_initialize(){
  set_choosewisely
  set_clearhistory

  if [ $choosewisely -eq 1 ]; then
    clear
    clear_all_files

    if [ $clearhistory -eq 1 ]; then
      clear_bash_history
      clear
      printf "\n[!] All logs, captures, and bash history have been cleared!\n"
      printf "[-] Unless of course you hid something...\n"
    else
      clear
      printf "\n[-] Skipping bash history clear\n"
      printf "[!] All logs and captures have been cleared!\n"
      printf "[-] Unless of course you hid something...\n"
    fi
  else

    clear
    if [ $clearhistory -eq 1 ]; then
      printf "\n[+] Bash history has been cleared!\n\n"
      printf "[+] Logs and captures have been left alone\n"
      printf "[!] Pwnies run wild!\n\n"
    else
      printf "\n[+] All logs, captures, and bash history have been left alone\n"
      printf "[!] Have a nice day! ^_^\n\n"
    fi
  fi
}

f_initialize
