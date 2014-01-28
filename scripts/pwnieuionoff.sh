#!/bin/bash
# Script to turn Pwnie UI off/on (on by default)

f_start_nginx(){
  echo "[+] Starting Pwnie User Interface...."
  service nginx start
  echo "[+] Done"
  echo
}

f_stop_nginx(){
  echo "[+] Stopping Pwnie User Interface...."
  service nginx stop
  echo "[+] Done"
  echo
}

clear
echo
echo "This script will enable / disable Pwnie UI https://localhost:1443"
echo

# check running processes to see if nginx is running

service nginx status &> /dev/null

if [ $? ]; then
  f_stop_nginx
else
  f_start_nginx
fi

