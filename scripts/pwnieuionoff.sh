#!/bin/bash
# Script to turn Pwnie UI off/on (on by default)

clear
echo
echo "This script will enable / disable Pwnie UI https://localhost:1443"
echo

# Check running processes to see if nginx is running
service nginx status &> /dev/null
NGINX_STATUS=$?

if [ $NGINX_STATUS -eq 0 ]; then
  echo "[+] Stopping Pwnie User Interface...."
  service nginx stop
  echo "[+] Done"
  echo
else
  echo "[+] Starting Pwnie User Interface...."
  service nginx start
  echo "[+] Done"
  echo
fi

