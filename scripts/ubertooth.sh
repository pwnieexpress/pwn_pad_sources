#!/bin/bash
# Desc: Ubertooth example script
#set the prompt to the name of the script
PS1=${PS1//@\\h/@ubertooth}
clear

f_banner(){
  printf "\nWelcome to the Ubertooth Toolkit\n\n"
  printf "Please select which tool to run:\n\n"
}

f_select(){
  printf "1) ubertooth lap detection\n"
  printf "2) ubertooth-dump\n"
  printf "3) ubertooth-btle\n"
  printf "4) check firmware version\n"
  printf "5) reset ubertooth\n\n"
  read -p "Choice: " selection

  trap f_hangup SIGHUP

  case $selection in
    1) if [ -x /usr/bin/ubertooth-rx ]; then
         ubertooth-rx
       elif [ -x /usr/bin/ubertooth-lap ]; then
         ubertooth-lap
       else
         printf "Unable to find ubertooth-rx or ubertooth-lap\n"
       fi
       ;;
    2) ubertooth-dump ;;
    3) ubertooth-btle -f ;;
    4) ubertooth-util -v ;;
    5) ubertooth-util -r ;;
    *) f_select ;;
  esac
}

f_hangup(){
  pkill ubertooth-*
  exit 1
}

f_run(){
  f_banner
  f_select
}

f_run
