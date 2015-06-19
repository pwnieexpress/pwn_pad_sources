#!/bin/bash
# Script to turn SSHD on and off
#set the prompt to the name of the script
PS1=${PS1//@\\h/@ssh_toggle}
clear

f_show_ip(){
  IP_SUBNET=$(ip addr show | awk '/inet / {print $2}')
  if [ -n "${IP_SUBNET}" ]; then
    printf "\nIPs currently assigned to system:\n"
    for i in $IP_SUBNET; do
      if [ "${i%/*}" != "127.0.0.1" ]; then
        printf "${i%/*}\n"
      fi
    done
  else
    printf "No current IP found.\n"
  fi
}

f_start_ssh(){
  printf "[+] Starting SSH server...\n"
  service ssh start
  /system/bin/setenforce 0
  printf "[!] Done\n"
  f_show_ip
}

f_stop_ssh(){
  printf "[-] Stopping SSH server...\n"
  service ssh stop
  printf "[!] Done\n\n"
}

printf "\n[-] This will enable/disable SSH server access on port 22\n\n"


#check running processes to see if ssh is running
service ssh status &> /dev/null
SSH_STATUS=$?

case "$SSH_STATUS" in
  0) f_stop_ssh ;;
  *) f_start_ssh ;;
esac

