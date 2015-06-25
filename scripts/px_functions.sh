#unified f_interface function abstract, plus some other misc functions
# variables consumed:
 : ${include_wired:=1}     # enable or disable eth0  (default on)
 : ${include_intwifi:=1}   # enable or disable wlan0 (default on)
 : ${include_extwifi:=1}   # enable or disable wlan1 (default on)
 : ${include_monitor:=1}   # enable or disable wlan1mon (default on)
 : ${include_airbase:=1}   # enable or disable at0 (default on)
 : ${include_cell:=0}      # enable or disable $gsm_int (default OFF)
 : ${include_usb:=1}       # enable or disable rndis0 (default on)
 : ${include_all:=0}       # enable everything (default OFF)
 : ${require_ip:=0}        # require an ip for the interface to show as available (default OFF)
 : ${message:="sniff on"}  # message for header
 : ${loud_one:=0}          # include warning output of f_validate_one
 : ${bluetooth:=0}         # are we looking for a bluetooth interface or not? (default OFF)
#  ${default_interface}    # contains default interface, if any

f_identify_device(){
# Check device
  if command -v /system/bin/getprop > /dev/zero 2>&1; then
    hardw=`/system/bin/getprop ro.hardware`
    if [[ "$hardw" == "deb" || "$hardw" == "flo" ]]; then
      # Set interface for new Pwn Pad
      ifconfig rmnet_usb0 > /dev/zero 2>&1
      if [ "$?" = "0" ]; then
        gsm_int="rmnet_usb0"
      else
        gsm_int="(not present)"
      fi
    else
      # Set interface for Pwn Phone and old Pwn Pad
      ifconfig rmnet0 > /dev/zero 2>&1
      if [ "$?" = "0" ]; then
        gsm_int="rmnet0"
      else
        gsm_int="(not present)"
      fi
    fi
  else
    #we don't have access to /system/bin/getprop, abort
    gsm_int="(not present)"
  fi
  if [ "$default_interface" = "gsm_int" ] && [ -n "$gsm_int" ]; then
    default_interface=$gsm_int
  fi
}

f_interface(){
  if [ "$require_ip" = "1" ]; then
    what_valid="have an IP on the target network"
  else
    what_valid="exist"
  fi

  f_identify_device

  clear
  printf "$naughty"
  printf "Select which interface to $message [1-7]:\n\n"
  printf "$(f_colorize eth0)1. eth0  (USB Ethernet adapter)$(f_isdefault eth0)\e[0m\n"
  printf "$(f_colorize wlan0)2. wlan0  (internal Wifi)$(f_isdefault wlan0)\e[0m\n"
  printf "$(f_colorize wlan1)3. wlan1  (USB TP-Link adapter)$(f_isdefault wlan1)\e[0m\n"
  printf "$(f_colorize wlan1mon)4. wlan1mon  (monitor mode interface)$(f_isdefault wlan1mon)\e[0m\n"
  printf "$(f_colorize at0)5. at0  (Use with EvilAP)$(f_isdefault at0)\e[0m\n"
  printf "$(f_colorize $gsm_int)6. $gsm_int (4G GSM connection)$(f_isdefault $gsm_int)\e[0m\n"
  printf "$(f_colorize rndis0)7. rndis0  (USB tether)$(f_isdefault rndis0)\e[0m\n"
  printf "\n"
  printf "NOTE: If selected interface is \e[1;31minvalid\e[0m, or \e[1;90mdisabled\e[0m, this menu will loop.\n"
  printf "      To be \e[1;32mvalid\e[0m, an interface must $what_valid.\n"
  read -p "Choice: " interfacechoice

  case $interfacechoice in
    1) interface=eth0 ;;
    2) interface=wlan0 ;;
    3) interface=wlan1 ;;
    4) interface=wlan1mon ;;
    5) interface=at0 ;;
    6) interface=$gsm_int ;;
    7) interface=rndis0 ;;
    0) include_all=1 naughty="Welcome Elite User!\n" f_interface  ;;
    *) interface=${default_interface} ;;
  esac
  if [ -n "$interface" ]; then
    f_validate_choice $interface
    RETVAL=$?
    if [ $RETVAL = 0 ]; then
      clear
    elif [ $RETVAL = 1 ]; then
      #invalid
      naughty="Interface \e[1;31m$interface\e[0m is an \e[1;31minvalid selection\e[0m.\n"
      f_interface
    elif [ $RETVAL = 2 ]; then
      #disabled
      naughty="Interface \e[1;90m$interface\e[0m is \e[1;90madministratively disabled\e[0m.\n"
      f_interface
    fi
  else
    f_interface
  fi
}

f_validate_choice(){
  if [ "$bluetooth" = "1" ]; then
    hciconfig $1 > /dev/zero 2>&1
    if [ $? = 0 ]; then
      return 0
    else
      return 1
    fi
  fi
  if [ "$include_all" != "1" ]; then
    #administratively disable interfaces
    if [ "$include_wired" != "1" ] && [ "$1" = "eth0" ]; then return 2; fi
    if [ "$include_intwifi" != "1" ] && [ "$1" = "wlan0" ]; then return 2; fi
    if [ "$include_extwifi" != "1" ] && [ "$1" = "wlan1" ]; then return 2; fi
    if [ "$include_monitor" != "1" ] && [ "$1" = "wlan1mon" ]; then return 2; fi
    if [ "$include_airbase" != "1" ] && [ "$1" = "at0" ]; then return 2; fi
    if [ "$include_cell" != "1" ] && [ "$1" = "$gsm_int" ]; then return 2; fi
    if [ "$include_usb" != "1" ] && [ "$1" = "rndis0" ]; then return 2; fi
  fi
  #valid actually holds 0 for good and 1 for bad, I know, I know.
  if [ "$1" = "wlan0" ]; then
    if [ -x /system/bin/getprop ]; then
      if [ "$(/system/bin/getprop wlan.driver.status)" = "unloaded" ]; then
        return 1
      fi
    fi
  fi
  ip addr show dev $1 > /dev/zero 2>&1
  local valid=$?
  if [ "$require_ip" = "1" ] && [ "$valid" = 0 ];then
    local has_ip="$(ip addr show dev $1 | awk '/inet / {print $2}')"
    if [ -z "$has_ip" ]; then
      valid=1
    fi
  fi
  return $valid
}

f_validate_one(){
  if ! $(f_validate_choice $1); then
    case $1 in
      wlan0) requirement="enable wireless in android" ;;
      wlan1) requirement="plug in a supported external wifi adapter" ;;
      wlan1mon) requirement="plug in a supported external wifi adapter" ;;
      at0) requirement="start evilap" ;;
      hci0) requirement="plug in a supported bluetooth adapter" ;;
      *) requirement="ensure $1 exists" ;;
    esac
    [ "$loud_one" = "1" ] && printf "Please $requirement to run this on $1.\n"
    return 1
  else
    return 0
  fi
}

f_colorize(){
  f_validate_choice $1
  RETVAL=$?
  if [ $RETVAL = 0 ]; then
    #green text for valid
    printf "\e[1;32m"
  elif [ $RETVAL = 1 ]; then
    #red text for invalid
    printf "\e[1;31m"
  elif [ $RETVAL = 2 ]; then
    #dark grey for disabled
    printf "\e[1;90m"
  else
    #blue on unknown
    printf "\e[1;34m"
  fi
}

f_isdefault(){
  if [ "$default_interface" = "$1" ]; then
    printf " (default)"
  fi
}

## Extra functions we can safely abstract
f_one_or_two(){
  read -p "Choice [1-2]: " input
  case $input in
    [1-2]*) printf "$input\n" ;;
    *)
      f_one_or_two
      ;;
  esac
}

#safe to call with or without monitor interface, returns 1 on fail and 0 if wlan1mon is available
f_mon_enable(){
  include_extwifi=1 include_monitor=1 require_ip=0
  if f_validate_one wlan1mon; then
    printf "Already have monitor mode interface wlan1mon available.\n"
    if f_validate_one wlan1; then
      printf "Attempting to remove unneeded wlan1 interface..."
      #set to down first or deb and flo crash
      ip link set wlan1 down
      iw dev wlan1 del &> /dev/null
      if [ $? = 0 ]; then
        printf "Success.\n"
      else
        printf "Failure.\n"
      fi
    fi
    unset ${interface}
    return 0
  elif loud_one=1 f_validate_one wlan1; then
    printf "Attempting to put wlan1 into monitor mode..."
    airmon-ng start wlan1 &> /dev/null
    if f_validate_one wlan1mon; then
      printf "Success, wlan1mon created.\n"
      unset ${interface}
      return 0
    else
      printf "Failed to create wlan1mon.\n"
      unset ${interface}
      return 1
    fi
  else
    printf "Unable to find a usable interface to put in monitor mode.\n"
    unset ${interface}
    return 1
  fi
}

#safe to call with or without a monitor interface, returns 1 on failure and 0 when wlan1 is in station mode
f_mon_disable(){
  include_extwifi=1 include_monitor=1 require_ip=0
  if f_validate_one wlan1mon; then
    printf "\n[?] Stay in monitor mode (wlan1mon)?\n\n"
    printf "1. Yes\n"
    printf "2. No\n\n"
    read -p "Choice [1 or 2]: " opt_mon
    case $opt_mon in
      1)
        printf "\n[!] wlan1mon is still up\n\n"
        ;;
      2)
        printf "\n[+] Taking wlan1mon out of monitor mode..."
        #this is to work around the fact that airodump-ng assumes you are allowed to
        #have two interfaces and deb/flo does not support that
        hardw=`/system/bin/getprop ro.hardware`
        if [[ "$hardw" == "deb" || "$hardw" == "flo" ]]; then
          PHY=$(cat /sys/class/net/wlan1mon/phy80211/name)
          iw dev wlan1mon del &> /dev/null
          f_validate_one wlan1 || iw phy $PHY interface add wlan1 type station &> /dev/null
        else
          airmon-ng stop wlan1mon &> /dev/null
        fi
        if f_validate_one wlan1mon; then
          printf "Failed, wlan1mon is still in monitor mode.\n"
        else
          printf "Success.\n"
        fi
        if f_validate_one wlan1; then
          ip link set wlan1 down &> /dev/null
          printf "Interface wlan1 is available in station mode.\n"
          return 0
        else
          printf "Failed to create wlan1 in station mode, you may have to remove and reinsert your wifi card.\n"
          return 1
        fi
        ;;
      *)f_mon_disable ;;
    esac
  else
    if f_validate_one wlan1; then
      printf "Interface wlan1 is already available in station mode.\n"
    else
      printf "All external wifi interfaces have disappeared, please remove and reattach your external wifi adapter.\n"
    fi
  fi
}

f_channel_list(){
  unset channel_list twofour_channels five_channels
  [ -z "$1" ] && return 1
  if [ -f /sys/class/net/$1/phy80211/name ]; then
    channel_list=$(iw phy $(cat /sys/class/net/$1/phy80211/name) info 2>&1 | grep -oP '\[\K[^\]]+')
  else
    channel_list="1 2 3 4 5 6 7 8 9 10 11"
  fi
  for i in $channel_list; do
    [ "$i" -lt 15 ] && twofour_channels="${twofour_channels} $i"
    [ "$i" -gt 14 ] && five_channels="${five_channels} $i"
  done
  return 0
}

f_validate_channel(){
  #must call f_channel_list first
  # $1 is interface
  # $2 is channel
  [ -z "$channel_list" ] && return 1
  [ -z "$1" ] && return 1
  [ -z "$2" ] && return 1
  VALID=1
  for i in $channel_list; do
    [ "$2" = "$i" ] && VALID=0
  done
  if [ "$VALID" = "0" ]; then
    ip link set $1 up > /dev/null 2>&1
    iw $1 set channel $2 > /dev/null 2>&1
    RETCODE=$?
    if [ "$RETCODE" = "0" ]; then
      return 0
    else
      return 3
    fi
  else
    return 2
  fi
  return 4
}
