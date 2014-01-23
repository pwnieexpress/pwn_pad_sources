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
NGINX_STATUS=$?

case "$NGINX_STATUS" in
  0) f_stop_nginx ;;
  *) f_start_nginx ;;
esac

