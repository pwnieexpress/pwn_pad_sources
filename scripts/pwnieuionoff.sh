#!/bin/bash
#Script to turn Pwnie UI off/on (on by default)

#check running processes to see if nginx is running, write to a file
netstat -antup |grep nginx > pwnie_ui_tmp

f_stop_ui(){
  echo
  echo
  echo "Stopping Pwnie User Interface...."
  service nginx stop
  echo "Done"
  echo
  echo "Stopping SSH Server..."
  service ssh stop
  echo "Done"
  echo
  echo
}

f_start_ui(){

  echo
  echo
  echo "Starting Pwnie User Interface...."
  service nginx start
  echo "Done"
  echo
  echo "Starting SSH Server..."
  service ssh start
  echo "Done"
  echo
  echo
}

#if file has a size (process is running) stop services
  if [ -s pwnie_ui_tmp ]
  then

  f_stop_ui

  else
  
  f_start_ui

  fi

#remove tmp file
rm -r pwnie_ui_tmp
