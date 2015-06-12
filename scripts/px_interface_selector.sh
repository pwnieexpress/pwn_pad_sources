#unified f_interface function abstract
# variables consumed:
#  include_extwifi   - enable or disable wlan1 (default on)
#  include_monitor   - enable or disable wlan1mon (default on)
#  include_airbase   - enable or disable at0 (default on)
#  include_cell      - enable or disable $gsm_int (default OFF)
#  include_usb       - enable or disable rndis0 (default on)
#  include_all       - enable everything (default OFF)
#  require_ip        - require an ip for the interface to show as available (default OFF)#
#  default_interface - contains default interface, if any

f_identify_device(){
# Check device
  if command -v /system/bin/getprop > /dev/zero 2>&1; then
    hardw=`/system/bin/getprop ro.hardware`
    if [[ "$hardw" == "deb" || "$hardw" == "flo" ]]; then
      # Set interface for new Pwn Pad
      ifconfig rmnet_usb0 > /dev/zero 2>&1
      if [ "$?" = "0" ]; then
        gsm_int="rmnet_usb0"
      fi
    else
      # Set interface for Pwn Phone and old Pwn Pad
      ifconfig rmnet0 > /dev/zero 2>&1
      if [ "$?" = "0" ]; then
        gsm_int="rmnet0"
      fi
    fi
  else
    #we don't have access to /system/bin/getprop, abort
    gsm_int=""
  fi
  if [ "$default_interface" = "gsm_int" ] && [ -n "$gsm_int" ]; then
    default_interface=$gsm_int
  fi
}

f_interface(){
  : ${include_extwifi:=1}
  : ${include_monitor:=1}
  : ${include_airbase:=1}
  : ${include_cell:=0}
  : ${include_usb:=1}
  : ${include_all:=0}
  : ${require_ip:=0}
  : ${message:="sniff on"}

  if [ "$require_ip" = "1" ]; then
    what_valid="have an IP on the target network"
  else
    what_valid="exist"
  fi

  if ( [ "$include_cell" = "1" ] || [ "$include_all" = "1" ] ) && [ -z "$gsm_int" ]; then
    f_identify_device
  fi
  clear
  printf "Select which interface to $message [1-7]:\n"
  printf "$naughty\n"
  printf "$(f_colorize eth0)1. eth0  (USB Ethernet adapter)$(f_isdefault eth0)\e[0m\n"
  printf "$(f_colorize wlan0)2. wlan0  (internal Wifi)$(f_isdefault wlan0)\e[0m\n"
  printf "$(f_colorize wlan1)3. wlan1  (USB TP-Link adapter)$(f_isdefault wlan1)\e[0m\n"
  printf "$(f_colorize wlan1mon)4. wlan1mon  (monitor mode interface)$(f_isdefault wlan1mon)\e[0m\n"
  printf "$(f_colorize at0)5. at0  (Use with EvilAP)$(f_isdefault at0)\e[0m\n"
  printf "$(f_colorize $gsm_int)6. $gsm_int (4G GSM connection)$(f_isdefault $gsm_int)\e[0m\n"
  printf "$(f_colorize rndis0)7. rndis0  (USB tether)$(f_isdefault rndis0)\e[0m\n"
  printf "\n"
  printf "NOTE: If selected interface is \e[1;31minvalid\e[0m, this menu will loop.\n"
  printf "      To be \e[1;32mvalid\e[0m, this interface must $what_valid.\n"
  read -p "Choice: " interfacechoice

  case $interfacechoice in
    1) interface=eth0 ;;
    2) interface=wlan0 ;;
    3) interface=wlan1 ;;
    4) interface=wlan1mon ;;
    5) interface=at0 ;;
    6) interface=$gsm_int ;;
    7) interface=rndis0 ;;
    0) include_all=1 f_interface  ;;
    *) interface=${default_interface} ;;
  esac
  if [ -n "$interface" ]; then
    f_validate_choice $interface || f_interface
  else
    f_interface
  fi
}

f_validate_choice(){
  if [ "$include_all" != "1" ]; then
    #administratively disable interfaces
    if [ "$include_extwifi" != "1" ] && [ "$1" = "wlan1" ]; then return 2; fi
    if [ "$include_monitor" != "1" ] && [ "$1" = "wlan1mon" ]; then return 2; fi
    if [ "$include_airbase" != "1" ] && [ "$1" = "at0" ]; then return 2; fi
    if [ "$include_cell" != "1" ] && [ "$1" = "$gsm_int" ]; then return 2; fi
    if [ "$include_usb" != "1" ] && [ "$1" = "rndis0" ]; then return 2; fi
  fi
  #valid actually holds 0 for good and 1 for bad, I know, I know.
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
      wlan1) requirement="plug in a supported external wifi adapter" ;;
      at0) requirement="start evilap" ;;
      hci0) requirement="plug in a supported bluetooth adapter" ;;
      *) requirement="ensure $1 exists" ;;
    esac
    printf "Please $requirement to run $(basename ${0%.*}).\n"
    exit 1
  fi
}

f_colorize(){
  f_validate_choice $1
  if [ $? = 0 ]; then
    #green text for valid
    printf "\e[1;32m"
  elif [ $? = 1 ]; then
    #red text for invalid
    printf "\e[1;31m"
  elif [ $? = 2 ]; then
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
