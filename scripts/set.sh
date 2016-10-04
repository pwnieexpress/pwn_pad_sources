#!/bin/bash
#Script to run Social Engineer Toolkit with no flags.
#set the prompt to the name of the script
PS1=${PS1//@\\h/@setoolkit}
clear

f_hangup(){
  pkill setoolkit
  exit 1
}

cd /opt/pwnix/captures/
if [ ! -f /etc/setoolkit/set.config ]; then
  echo 99 | setoolkit > /dev/null 2>&1
fi
if grep -q "APACHE_SERVER=ON" /etc/setoolkit/set.config; then
  sed -i 's#APACHE_SERVER=ON#APACHE_SERVER=OFF#' /etc/setoolkit/set.config
fi
clear

trap f_hangup SIGHUP

setoolkit
