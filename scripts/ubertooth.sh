#!/bin/bash
#Desc: Ubertooth example script

f_run(){

clear

echo
echo "This shortcut is designed to show you the ubertooth tool suite is installed"
echo

echo "Please select which tool to run:"
echo '

      1. [ubertooth-lap]
      2. ubertooth-dump
      3. ubertooth-btle
	'
read -p "Choice: " selectedtool

        case $selectedtool in
        1) f_lap ;;
        2) f_dump ;;
        3) f_btle ;;
        *) f_lap ;;
        esac

}

#########################################
f_lap(){

  ubertooth-lap
}

#########################################
f_dump(){

  ubertooth-dump
}

#########################################
f_btle(){

  ubertooth-btle -f
}

f_run
