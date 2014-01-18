#!/bin/bash
# Desc: Ubertooth example script

f_banner(){
  clear
  echo "Welcome to the Ubertooth Toolkit"
  echo
  echo "Please select which tool to run:"
  echo
}

f_select(){
  echo "1) ubertooth-lap"
  echo "2) ubertooth-dump"
  echo "3) ubertooth-btle"
  read -p "Choice: " selection
}

f_run(){
  f_banner
  f_select
  case $selection in
    1) ubertooth-lap ;;
    2) ubertooth-dump ;;
    3) ubertooth-btle -f ;;
    *) f_select ;;
  esac
}

f_run
