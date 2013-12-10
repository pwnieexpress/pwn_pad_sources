#!/bin/bash
#Script to turn Pwnie UI off/on (on by default)



f_start_nginx(){

  echo
  echo
  echo "Starting Pwnie User Interface...."
  service nginx start
  echo
  echo "Done"
  echo

}

f_stop_nginx(){
  echo
  echo
  echo "Stopping Pwnie User Interface...."
  service nginx stop
  echo
  echo "Done"
  echo 
}

f_start_ssh(){

  echo
  echo "Starting SSH Server..."
  service ssh start
  echo
  echo "Done"
  echo
  echo
}

f_stop_ssh(){

  echo
  echo "Stopping SSH Server..."
  service ssh stop
  echo
  echo "Done"
  echo
  echo
}

clear
echo "This script will enable / disable Pwnie UI https://pwnpadsIPaddress:1443"
echo 
echo "This script will enable / disable SSH Server access on port 22"
echo
sleep 1


#check running processes to see if nginx is running

service nginx status &> /dev/null
NGINX_STATUS=$?

case "$NGINX_STATUS" in
  0) f_stop_nginx ;;
  *) f_start_nginx ;;
esac


#check running processes to see if ssh is running

service ssh status &> /dev/null
SSH_STATUS=$?

case "$SSH_STATUS" in
  0) f_stop_ssh ;;
  *) f_start_ssh ;;
esac

