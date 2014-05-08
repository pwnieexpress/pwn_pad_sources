#!/bin/bash
# Script to turn Pwnie UI off/on (ON by default)

clear
echo "This will enable/disable the Pwnie UI at https://localhost:1443"
echo

# Check running processes to see if nginx is running
service nginx status &> /dev/null
NGINX_STATUS=$?

if [ $NGINX_STATUS -eq 0 ]; then
  echo "[-] Stopping Pwnie user interface..."
  service nginx stop
  killall nginx
  echo "[!] Done"
  echo
else
  echo "[+] Starting Pwnie user interface..."
  service nginx start
  echo "[!] Done"
  echo
fi

