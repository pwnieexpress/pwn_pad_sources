#!/bin/bash
# Script to turn Pwnie UI off/on (ON by default)
clear

printf "\nThis will enable/disable the Pwnie UI at https://localhost:1443\n\n"

# Check running processes to see if nginx is running
service nginx status &> /dev/null
NGINX_STATUS=$?

if [ $NGINX_STATUS -eq 0 ]; then
  printf "[-] Stopping Pwnie user interface...\n"
  service nginx stop
  killall nginx
  printf "[!] Done\n\n"
else
  printf "[+] Starting Pwnie user interface...\n"
  service nginx start
  printf "[!] Done\n\n"
fi

