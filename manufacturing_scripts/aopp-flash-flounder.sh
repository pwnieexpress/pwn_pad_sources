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

f_pause(){
  read -p "$*"
}

f_run(){

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

  # Kill server if one is already running
  if [[ -n "$(pgrep adb)" ]]; then
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

  # Count devices
  device_count="$(fastboot devices | wc -l)"

  # Store serials
  j="0"
  while read line
  do
    serial_array["${j}"]="${line}"
    (( j++ ))
  done < <(fastboot devices | cut -c 1-12)

  # Print devices
  if [[ "${device_count}" -gt "1" ]]
  then
    echo "There are ${device_count} devices connected: "
  elif [[ "${device_count}" -eq "1" ]]
  then
    echo "There is 1 device connected: "
  else
    echo "There are no devices connected. Exiting now."
    exit 1
  fi
  fastboot devices
}

f_unlock() {

  # Unlock bootloader
  echo
  echo "[+] Unlock the device"
  k=0
  while (( "${k}" -lt "${device_count}" ))
  do
    fastboot oem unlock -s "${serial_array["${k}"]}" &
    (( k++ ))
  done
  wait

  # Wait for unlock
  devices="$(fastboot devices | wc -l)"
  while (( "${devices}" -lt 1 ))
  do
    sleep 1
  done
  wait

  # Flash recovery
  echo
  echo "[+] Flash recovery"
  k=0
  while (( "${k}" -lt "${device_count}" ))
  do
    fastboot flash recovery twrp-3.0.2-0-flounder.img -s "${serial_array["${k}"]}" &
    sleep 1
    (( k++ ))
  done
  wait

  # Format system
  echo
  echo "[+] Erase and format system"
  k=0
  while (( "${k}" -lt "${device_count}" ))
  do
    fastboot format system -s "${serial_array["${k}"]}" &
    (( k++ ))
  done
  wait
}

f_setup() {

  # Boot into recovery
  echo
  echo "[+] Boot into recovery"
  k=0
  while (( "${k}" -lt "${device_count}" ))
  do
    fastboot boot twrp-3.0.2-0-flounder.img -s "${serial_array["${k}"]}" &
    sleep 1
    (( k++ ))
  done
  wait

  echo
  f_pause "[!] Swipe to allow modifications. Press [ENTER] to continue."

  # Remove old chroot files
  echo
  echo "[+] Remove old chroot files"
  k=0
  while (( "${k}" -lt "${device_count}" ))
  do
    adb -s "${serial_array[${k}]}" shell rm -rf /sdcard/Android/data/com.pwnieexpress.android.pxinstaller/files/* &
    (( k++ ))
  done
  wait

  # Format userdata
  echo
  echo "[+] Erase and format userdata"
  k=0
  while (( "${k}" -lt "${device_count}" ))
  do
    adb -s "${serial_array["${k}"]}" shell twrp wipe data &
    (( k++ ))
  done
  wait

  # Format cache
  echo
  echo "[+] Erase and format cache"
  k=0
  while (( "${k}" -lt "${device_count}" ))
  do
    adb -s "${serial_array["${k}"]}" shell twrp wipe cache &
    (( k++ ))
  done
  wait

  # Format dalvik-cache
  echo
  echo "[+] Erase and format dalvik-cache"
  k=0
  while (( "${k}" -lt "${device_count}" ))
  do
    adb -s "${serial_array["${k}"]}" shell twrp wipe dalvik &
    (( k++ ))
  done
  wait
}

f_flash() {

  # Push rom zip
  echo
  echo "[+] Push ROM zip"
  k=0
  while (( "${k}" -lt "${device_count}" ))
  do
    adb -s "${serial_array[$k]}" push aopp-0.1-20160523-UNOFFICIAL-flounder_lte.zip /sdcard/ &
    sleep 1
    (( k++ ))
  done
  wait

  # Flash rom zip
  echo
  echo "[+] Flash ROM zip"
  k=0
  while (( "${k}" -lt "${device_count}" ))
  do
    adb -s "${serial_array[${k}]}" shell twrp install /sdcard/aopp-0.1-20160523-UNOFFICIAL-flounder_lte.zip &
    sleep 1
    (( k++ ))
  done
  wait
 
  # Reboot
  echo
  echo "[+] Reboot"
  echo 
  k=0
  while (( "${k}" -lt "${device_count}" ))
  do
    adb -s "${serial_array["${k}"]}" reboot &
    (( k++ ))
  done
  wait
}

f_run
f_unlock
f_setup
f_flash
