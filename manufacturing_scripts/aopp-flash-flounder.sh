#!/bin/bash
# Target: Nexus 9 (flounder/flounder_lte)
# Action: Wipes target device and installs Aopp ROM
# Result: Pwn Pad 
# Author: josefelipe
# Company: Pwnie Express
# Contact: josefelipe@pwnieexpress.com

# Increase strictness by making script exit to catch potential bugs caused by
# failed commands or unset variables
set -e
set -u

# Set rom variable at top for easy editing
rom="aopp-0.1-20160523-UNOFFICIAL-flounder_lte.zip"

# Have the option to read ROM version from command line
while getopts ":r:" FLAG; do
  case "${FLAG}" in
    r)
      rom="${OPTARG}"
    ;;
   esac
done

kill_server() {
  killall adb &> /dev/null
}
trap 'killall adb &> /dev/null' EXIT

check_rom() {
  if ! [ -f "${rom}" ]; then
    echo "ROM '${rom}' does not exist. Exiting now."
    exit 1
  fi
}

check_dependencies() {
  # Have dependency checking to ensure users know which packages to install
  # on a new system
  dependencies=(
    adb
    fastboot
  )
  for command in "${dependencies[@]}"; do
    if ! [ -x "$(command -v "${command}")" ]; then
      echo
      echo "Command '${command}' not found. Please have android-tools-adb and android-tools-fastboot packages installed." >&2
      exit 1
    fi
  done
}

f_pause() {
  read -p "$*"
}

f_run() {
  # Splash
  clear
  echo " "
  echo "    /\  __ \   /\ '-.\ \   /\  __-.  /\  == \   /\  __ \   /\ \   /\  __-.           " 
  echo "    \ \  __ \  \ \ \-.  \  \ \ \/\ \ \ \  __<   \ \ \/\ \  \ \ \  \ \ \/\ \          "
  echo "     \ \_\ \_\  \ \_\\ '\_\  \ \____-  \ \_\ \_\  \ \_____\  \ \_\  \ \____-          "
  echo "      \/_/\/_/   \/_/ \/_/   \/____/   \/_/ /_/   \/_____/   \/_/   \/____/          "
  echo " 										     "
  echo "  /\  __ \   /\  == \ /\  ___\   /\ '-.\ \      /\  == \ /\ \  _ \ \   /\ '-.\ \     " 
  echo "  \ \ \/\ \  \ \  _-/ \ \  __\   \ \ \-.  \     \ \  _-/ \ \ \/ '.\ \  \ \ \-.  \    " 
  echo "   \ \_____\  \ \_\    \ \_____\  \ \_\\ '\_\     \ \_\    \ \__/'.~\_\  \ \_\\ '\_\   " 
  echo "    \/_____/   \/_/     \/_____/   \/_/ \/_/      \/_/     \/_/   \/_/   \/_/ \/_/   "
  echo "  										     "
  echo "       /\  == \ /\  == \   /\  __ \     /\ \   /\  ___\   /\  ___\   /\__  _\ 	     "
  echo "       \ \  _-/ \ \  __<   \ \ \/\ \   _\_\ \  \ \  __\   \ \ \____  \/_/\ \/ 	     "
  echo "        \ \_\    \ \_\ \_\  \ \_____\ /\_____\  \ \_____\  \ \_____\    \ \_\ 	     "
  echo "         \/_/     \/_/ /_/   \/_____/ \/_____/   \/_____/   \/_____/     \/_/  	     "
  echo "										     "
  echo "                                                       		                     "
  echo "                        	-----------------------             	             "
  echo "                               	 RUN THIS TOOL AS ROOT                               "
  echo "                        	-----------------------                              "  
  echo "                                                                                     "
  echo "                                --= Pwn Pad Builder =--                              "
  echo "          	    A Mobile Pentesting Platform from Pwnie Express                  "
  echo "                                                                                     "
  echo " 	----------------------------------------------------------------------       "
  echo "  	        WARNING: THIS WILL WIPE ALL APPS AND DATA ON THE DEVICE.  	     "
  echo "  	Pwnie Express is not responsible for any damages resulting from the          "
  echo "  	use of this tool. Backup critical data before continuing.                    "
  echo " 	----------------------------------------------------------------------       "
  echo "                                                                                     "
  echo " 	Boot device into fastboot mode and attach to host machine.                   "
  echo
  f_pause " Press [ENTER] to continue, CTRL+C to abort. "

  # Check for root
  if [[ "${EUID}" -ne "0" ]]; then
    echo    
    echo " [!] This tool must be run as root [!]"
    echo    
    exit 1
  fi

  check_rom

  # Kill server if one is already running
  if [[ -n "$(pgrep adb)" ]]; then
    echo
    echo "Killing server"
    killall adb &> /dev/null
  fi

  # Start server
  echo
  adb start-server

  # Snag serials
  f_getserial
  echo
}

f_getserial() {
  devices="$(fastboot devices)"
  
  if [[ -z "${devices}" ]]; then
    echo "There are no devices connected. Exiting now."
    killall adb &> /dev/null
    exit 1
  fi

  serial_array=()
  
  for device in ${devices}; do
    serial_array+=("${device:0:12}")
  done 

  device_count="${#serial_array[@]}"
  
  if [[ "${device_count}" -gt "1" ]]; then
    echo "There are ${device_count} devices connected: "
  else
    echo "There is 1 device connected: "
  fi
  
  echo "${devices}"
}

f_unlock() {
  # Unlock bootloader
  echo
  echo "[+] Unlock the device"
  for device in "${serial_array[@]}"; do
    fastboot oem unlock -s "${device}"
  done
  wait

  # Wait for unlock
  while (( "${device_count}" -lt 1 )); do
    sleep 1
  done
  wait

  # Flash recovery
  echo
  echo "[+] Flash recovery"
  for device in "${serial_array[@]}"; do
    fastboot flash recovery twrp-3.0.2-0-flounder.img -s "${device}" &
    sleep 1
  done
  wait

  # Format system
  echo
  echo "[+] Erase and format system"
  for device in "${serial_array[@]}"; do
    fastboot format system -s "${device}"
  done
  wait
}

f_setup() {
  # Boot into recovery
  echo
  echo "[+] Boot into recovery"
  for device in "${serial_array[@]}"; do
    fastboot boot twrp-3.0.2-0-flounder.img -s "${device}" &
    sleep 1
  done
  wait

  echo
  f_pause "[!] Swipe to allow modifications. Press [ENTER] to continue."

  # Remove old chroot files
  echo
  echo "[+] Remove old chroot files"
  for device in "${serial_array[@]}"; do
    adb -s "${device}" shell rm -rf /sdcard/Android/data/com.pwnieexpress.android.pxinstaller/files/*
  done
  wait

  # Format userdata
  echo
  echo "[+] Erase and format userdata"
  for device in "${serial_array[@]}"; do 
   adb -s "${device}" shell twrp wipe data
  done
  wait

  # Format cache
  echo
  echo "[+] Erase and format cache"
  for device in "${serial_array[@]}"; do
    adb -s "${device}" shell twrp wipe cache
  done
  wait

  # Format dalvik-cache
  echo
  echo "[+] Erase and format dalvik-cache"
  for device in "${serial_array[@]}"; do 
    adb -s "${device}" shell twrp wipe dalvik
  done
  wait
}

f_flash() {
  # Push rom zip
  echo
  echo "[+] Push ROM zip"
  for device in "${serial_array[@]}"; do
    adb -s "${device}" push "${rom}" /sdcard/ &
    sleep 1
  done
  wait

  # Flash rom zip
  echo
  echo "[+] Flash ROM zip"
  for device in "${serial_array[@]}"; do
    adb -s "${device}" shell twrp install "/sdcard/${rom}" &
    sleep 1
  done
  wait
 
  # Reboot
  echo
  echo "[+] Reboot"
  echo 
  for device in "${serial_array[@]}"; do
    adb -s "${device}" reboot
  done
  wait
}

check_dependencies
f_run
f_unlock
f_setup
f_flash
