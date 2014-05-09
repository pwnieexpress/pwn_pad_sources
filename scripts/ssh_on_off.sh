#!/bin/bash
# Script to turn SSHD on and off

f_start_ssh(){
  echo "[+] Starting SSH server..."
  service ssh start
  echo "[!] Done"
  echo
}

f_stop_ssh(){
  echo "[-] Stopping SSH server..."
  service ssh stop
  echo "[!] Done"
  echo
}

clear
echo
echo "[-] This will enable/disable SSH server access on port 22"
echo


#check running processes to see if ssh is running
service ssh status &> /dev/null
SSH_STATUS=$?

case "$SSH_STATUS" in
  0) f_stop_ssh ;;
  *) f_start_ssh ;;
esac

