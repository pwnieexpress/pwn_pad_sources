#!/bin/bash

#check for rsa key, if not there generate and continue

f_modprobe(){
#load all modules for external adapters:
mkdir -p /dev/net/
ln -s /dev/tun /dev/net/tun
modprobe ath9k_htc
modprobe btusb
modprobe tun
}

f_rootsh(){

f_modprobe
/etc/init.d/ssh start
#modprobe ath9k_htc
ssh -t root@localhost "cd /opt/pwnpad/ ; clear ; bash"
}

f_checksshkey(){

  ls -a /root/.ssh/id_rsa |grep id_rsa > ssh_key_status

  if [ -s ssh_key_status ]
  then
  f_rootsh

  else 
  clear
  echo "This is your first time running the rootshell, a unique ssh key must me generated"
  echo 
  echo "Please hit enter for each step"
  echo
  ssh-keygen -t rsa
  cat /root/.ssh/id_rsa.pub > /root/.ssh/authorized_keys
  f_rootsh 
  fi
}
f_checksshkey
