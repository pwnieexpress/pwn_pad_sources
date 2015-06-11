#!/bin/bash
# Script to turn SSHD on and off

f_show_ip(){
  IP_SUBNET=$(ip addr show | awk '/inet / {print $2}')
  if [ -n "${IP_SUBNET}" ]; then
    printf "\nIPs currently assigned to system:\n"
    for i in $IP_SUBNET; do
      printf "${i%/*}\n"
    done
  else
    printf "No current IP found.\n"
  fi
}

f_start_ssh(){
  echo "[+] Starting SSH server..."
  service ssh start
  /system/bin/setenforce 0
  echo "[!] Done"
  f_show_ip
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

