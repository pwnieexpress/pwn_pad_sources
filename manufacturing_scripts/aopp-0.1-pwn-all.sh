#!/bin/bash
# Target: All Pwnie Express officially supported mobile devices
# Action: Unlocks bootloader, flashes custom boot and recovery, then restores backup and sets up chroot environment
# Result: Pwnify all
# Author: t1mz0r tim@pwnieexpress.com
# Author: Zero_Chaos zero@pwnieexpress.com
# Company: Pwnie Express

f_pause(){
  printf "$@"
  read
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

killserver() {
  if [ -n "$(pgrep adb)" ]; then
    #first the hand
    adb kill-server
    sleep 1
    #then the fist
    pkill -9 adb
  fi
}

f_run(){

  # Splash
  clear
  echo "       __ __      _ _  _ ____ ___   ___ _  _ ___ ___ ___ ___ ___       "
  echo "      | _ \ \    / | \| |_  _| __| | __\ \/ / _ \ _ \ __| __/ __/      "
  echo "      | _ /\ \/\/ /| .\ |_||_| _|  | _| >  <| _ / _ / _|\__ \__ \      "
  echo "      |_|   \_/\_/ |_|\_|____|___| |___/_/\_\_| |_|_\___|___/___/      "
  echo "                                                                       "
  echo "                       -------------------------                       "
  echo "                         RUN THIS TOOL AS ROOT                         "
  echo "                       -------------------------                       "
  echo "                                                                       "
  echo "                       --= All Pwn Builder =--                         "
  echo "           A Mobile Pentesting platform from Pwnie Express             "
  echo "                                                                       "
  echo " ----------------------------------------------------------------------"
  echo "  WARNING: THIS WILL WIPE ALL DATA AND INSTALL PACKAGES ON THE DEVICE. "
  echo "  Pwnie Express is not responsible for any damages resulting from the  "
  echo "  use of this tool. Backup critical data before continuing.            "
  echo " ----------------------------------------------------------------------"
  echo "                                                                       "

  echo ' Boot (n) devices into fastboot mode and attach to host machine.'
  echo
  f_pause ' Press [ENTER] to continue, CTRL+C to abort. '
  echo

# Check for root
  if [[ $EUID -ne 0 ]]; then
    printf '\n [!] This tool may need to be run as root [!]\n\n'
  fi

  #f_verify_flashables #no sha512sums on the downloads right now

  # Kill running server
  killserver

  # Start server
  adb start-server
  echo

  trap killserver SIGINT SIGTERM EXIT

  # Snag serials
  f_getserial
  #get the product
  f_getproduct
  #set pwnie names
  f_setpwnieproduct
  #set flash files
  f_setflashables
  echo

  #For Dallas, remove when the script can support threaded flashing
  fastboot devices | awk '{print $1}'

  # Get builder
  printf "[!] Enter your initials for the log and press [ENTER] to flash, CTRL+C to abort: "
  read initials

  # Log serials
  f_logserial
}

f_unlock() {
  # Unlock bootloader
  echo
  echo '[+] Unlock the device(s)'
  k=0
  while (( $k < $device_count ))
  do
    fastboot oem unlock -s ${serial_array[$k]} &
    WAITPIDS="$WAITPIDS "$!
    (( k++ ))
  done
  wait $WAITPIDS
  unset WAITPIDS
  echo
  echo '...device(s) have been unlocked.'
}

f_handle_recovery() {
  # Flash recovery
  echo
  echo '[+] Flash recovery'
  k=0
  while (( $k < $device_count ))
  do
    fastboot flash recovery ${image_base[$k]}/${recovery[$k]} -s ${serial_array[$k]} &
    WAITPIDS="$WAITPIDS "$!
    (( k++ ))
  done
  wait $WAITPIDS
  unset WAITPIDS

  ## better to just reboot into recovery or flash into recovery?
  # We should randomize this for fun
  #k=0
  #while (( $k < $device_count ))
  #do
  #  adb -s ${serial_array[$k]} reboot recovery &
  #  WAITPIDS="$WAITPIDS "$!
  #  (( k++ ))
  #done
  #wait $WAITPIDS
  #unset WAITPIDS

  # Boot into recovery
  echo
  echo '[+] Boot into recovery'
  k=0
  while (( $k < $device_count ))
  do
    fastboot boot ${image_base[$k]}/${recovery[$k]} -s ${serial_array[$k]} &
    WAITPIDS="$WAITPIDS "$!
    (( k++ ))
  done
  wait $WAITPIDS
  unset WAITPIDS

  k=0
  while (( $k < $device_count ))
  do
    sleepy_time[$k]=0
    while ! adb -s ${serial_array[$k]} shell true > /dev/null 2>&1; do
      sleep 1
      (( sleepy_time[$k]++ ))
      printf "Waiting on ${serial_array[$k]} to boot recovery for ${sleepy_time[$k]} seconds.\n"
    done
    (( k++ ))
  done
}

f_check_bootloader() {
  k=0
  while (( $k < $device_count ))
  do
    if [ -n "${bootloader[$k]}" ]; then
      ro_bootloader=$(adb -s "${serial_array[$k]}" shell getprop ro.bootloader)
      #ro_bootloader is $'version\r'
      if [ "${ro_bootloader}" != "${bootloader[$k]}" ]; then
        echo "Bootloader ${bootloader[$k]} is required but ${ro_bootloader} is installed. Quitting"
        exit 1
      fi
    fi
    (( k++ ))
  done
}

f_wipe() {
  # Remove old chroot files
  echo
  echo "[+] Remove old chroot files"
  k=0
  while (( $k < $device_count ))
  do
    adb -s "${serial_array[$k]}" shell rm -rf /sdcard/Android/data/com.pwnieexpress.android.pxinstaller/files/*
    (( k++ ))
  done

  # Format userdata
  echo "[+] Erase and format userdata"
  k=0
  while (( $k < $device_count ))
  do
    adb -s "${serial_array[$k]}" shell twrp wipe data &
    WAITPIDS="$WAITPIDS "$!
    (( k++ ))
  done
  wait $WAITPIDS
  unset WAITPIDS

  # Format cache
  echo "[+] Erase and format cache"
  k=0
  while (( $k < $device_count ))
  do
    adb -s "${serial_array[$k]}" shell twrp wipe cache &
    WAITPIDS="$WAITPIDS "$!
    (( k++ ))
  done
  wait $WAITPIDS
  unset WAITPIDS

  #Format dalvik-cache
  echo "[+] Erase and format dalvik-cache"
  k=0
  while (( $k < $device_count ))
  do
    adb -s "${serial_array[$k]}" shell twrp wipe dalvik &
    WAITPIDS="$WAITPIDS "$!
    (( k++ ))
  done
  wait $WAITPIDS
  unset WAITPIDS
}

f_logserial(){

  # Log serials
  k=0
  while (( $k < $device_count ))
  do
	echo "[${pwnie_product[$k]} on ${product_array[$k]}] ${serial_array[$k]} $(date) - $initials" | tee -a serial_datetime.txt
	(( k++ ))
  done
}

f_getserial(){

  # Count devices
  device_count=$(fastboot devices |wc -l)

  # Print devices
  if [ "$device_count" = "0" ]; then
    echo "There are no devices connected. Exiting now."
    exit 1
  elif [ "$device_count" != "1" ]; then
	  echo "There are $device_count devices connected"
  else
	  echo "There is 1 device connected:"
  fi

  # Store serials
  i=0
  while read line
  do
   	serial_array[$i]="$line"
   	(( i++ ))
  done < <(fastboot devices | awk '{print $1}')

}

f_getproduct(){
  k=0
  while (( $k < $device_count ))
  do
    product_array[$k]=$(fastboot -s ${serial_array[$k]} getvar product 2>&1 | grep "product" | awk '{print $2}')
    (( k++ ))
  done
}

f_setpwnieproduct(){
  k=0
  while (( $k < $device_count ))
  do
    case ${product_array[$k]} in
      grouper) pwnie_product[$k]="Pwn Pad 2013" ;;
      tilapia) pwnie_product[$k]="Pwn Pad 2013" ;;
      flo) pwnie_product[$k]="Pwn Pad 2014" ;;
      deb) pwnie_product[$k]="Pwn Pad 2014" ;;
      hammerhead) pwnie_product[$k]="Pwn Phone 2014" ;;
      ShieldTablet) pwnie_product[$k]="Pwn Pad 3" ;;
      *) printf "Unsupported product ${product_array[$k]}\n"; exit 1 ;;
    esac
    (( k++ ))
  done
}

f_setflashables(){
  k=0
  while (( $k < $device_count ))
  do
    #this is where we set the file locations
    case "${pwnie_product[$k]}" in
      "Pwn Pad 2013") image_base[$k]="$(pwd)/nexus_2012" recovery[$k]="twrp-2.8.6.0-grouper.img" ;;
      "Pwn Pad 2014") image_base[$k]="$(pwd)/nexus_2013" recovery[$k]="openrecovery-twrp-2.6.3.0-deb.img" ;;
      "Pwn Phone 2014")
        image_base[$k]="$(pwd)/hammerhead"
        rom[$k]="aopp-0.1-20160817-EXPERIMENTAL-hammerhead.zip"
        recovery[$k]="twrp-3.0.2-0-hammerhead.img"
        bootloader[$k]="HHZ12h"
        ;;
      "Pwn Pad 3") image_base[$k]="$(pwd)/shield-tablet" recovery[$k]="twrp-2.8.6.0-shieldtablet.img" ;;
      *) printf "Unknown flashables ${pwnie_product[$k]}\n"; exit 1 ;;
    esac
    (( k++ ))
  done
}

f_one_or_two(){
  printf "1.) Yes\n2.) No\n\n"
  printf "Choice [1-2]: "
  read input
  case $input in
    [1-2]*) return $input ;;
    *)
      f_one_or_two
      ;;
  esac
}

f_verify_flashables(){
  printf "Would you like to verify available images?\n\n"
  f_one_or_two
  VERIFY="$?"
  if [ "$VERIFY" = "1" ]; then
    printf "Checking files, please stand by...\n\n"
    for i in "$(pwd)/nexus_2012" "$(pwd)/nexus_2013"  "$(pwd)/nexus_5" "$(pwd)/shield-tablet"; do
      pushd "$i" &> /dev/null
      sha512sum --status -c checksums.sha512
      if [ $? = 0 ]; then
        printf "Files in $i are good to go, ready to flash.\n"
      else
        printf "Files in $i are corrupt, unable to flash.\n"
        f_pause "Press enter if you are *sure* you won't be needing the missing/corrupt files or ^C to quit and fix your files"
      fi
      popd &> /dev/null
    done
  fi
}

f_push(){
  # Push image to be installed
  echo
  echo '[+] Push AOPP Image'
  k=0
  while (( $k < $device_count ))
  do
    adb -s ${serial_array[$k]} push -p ${image_base[$k]}/${rom[$k]} /sdcard/ &
    WAITPIDS="$WAITPIDS "$!
    (( k++ ))
  done
  wait $WAITPIDS
  unset WAITPIDS

  # Push Kali chroot
  k=0
  while (( $k < $device_count ))
  do
    if [ "${pwnie_product[$k]}" != "Pwn Pad 3" ]; then
      adb -s ${serial_array[$k]} push -p chroot/stockchroot.sfs /sdcard/Android/data/com.pwnieexpress.android.pxinstaller/files/ &
      WAITPIDS="$WAITPIDS "$!
    fi
    (( k++ ))
  done
  wait $WAITPIDS
  unset WAITPIDS
}

f_install() {
  k=0
  while (( $k < $device_count ))
  do
    if [ "${pwnie_product[$k]}" != "Pwn Pad 3" ]; then
      adb -s ${serial_array[$k]} shell twrp install "/sdcard/${rom[$k]}" &
      WAITPIDS="$WAITPIDS "$!
    fi
    (( k++ ))
  done
  wait $WAITPIDS
  unset WAITPIDS
}

check_dependencies
f_run
f_unlock
f_handle_recovery
f_check_bootloader
f_wipe
f_push
f_install
