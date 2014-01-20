#!/bin/bash
# Script to turn SSHD on and off

f_start_ssh(){
  echo "[+] Starting SSH Server..."
  service ssh start
  echo "[+] Done"
}

f_stop_ssh(){
  echo "[+] Stopping SSH Server..."
  service ssh stop
  echo "[+] Done"
}

clear
echo
echo "This script will enable / disable SSH Server access on port 22"
echo
sleep 1


#check running processes to see if ssh is running
service ssh status &> /dev/null
SSH_STATUS=$?

case "$SSH_STATUS" in
  0) f_stop_ssh ;;
  *) f_start_ssh ;;
esac

