#!/bin/bash
# Desc: Ubertooth example script
clear

f_banner(){
  printf "\nWelcome to the Ubertooth Toolkit\n\n"
  printf "Please select which tool to run:\n\n"
}

f_select(){
  printf "1) ubertooth-lap\n"
  printf "2) ubertooth-dump\n"
  printf "3) ubertooth-btle\n\n"
  read -p "Choice: " selection

  case $selection in
    1) ubertooth-lap ;;
    2) ubertooth-dump ;;
    3) ubertooth-btle -f ;;
    *) f_select ;;
  esac
}

f_run(){
  f_banner
  f_select
}

f_run
