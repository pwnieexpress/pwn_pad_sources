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

selinuxfs() {
  if [ -z "${1}" ]; then
    printf "selinuxfs must be called with lock or unlock\n"
    exit 1
  fi
  case $1 in
    lock)
      if [ "${SELINUX_RO}" = "1" ] && [ -w /sys/fs/selinux ]; then
        mount -o remount,ro,bind /sys/fs/selinux
      elif [ -z "${SELINUX_RO}" ]; then
        printf "selinuxfs lock cannot be called until after unlock\n"
        exit 1
      fi
      ;;
    unlock)
      if mount | grep -q '/sys/fs/selinux' && [ ! -w /sys/fs/selinux ]; then
        mount -o remount,rw,bind /sys/fs/selinux
        SELINUX_RO="1"
      else
        SELINUX_RO="0"
      fi
      ;;
  esac
}

f_start_ssh(){
  printf "[+] Starting SSH server...\n"
  service ssh start
  selinuxfs unlock
  /system/bin/setenforce 0 > /dev/null 2>&1
  selinuxfs lock
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

