#!/bin/bash
# Target: All Pwnie Express officially supported mobile devices
# Action: Unlocks bootloader, flashes custom boot and recovery, then restores backup and sets up chroot environment
# Result: Pwnify any supported mobile device
# Author: t1mz0r tim@pwnieexpress.com
# Author: Zero_Chaos zero@pwnieexpress.com
# Company: Pwnie Express

DEBUG_FILE="debug.out"

f_pause(){
  printf "$@"
  read
}

f_run(){

  # Splash
  clear
  printf "       __ __      _ _  _ ____ ___   ___ _  _ ___ ___ ___ ___ ___       \n"
  printf "      | _ \ \    / | \| |_  _| __| | __\ \/ / _ \ _ \ __| __/ __/      \n"
  printf "      | _ /\ \/\/ /| .\ |_||_| _|  | _| >  <| _ / _ / _|\__ \__ \      \n"
  printf "      |_|   \_/\_/ |_|\_|____|___| |___/_/\_\_| |_|_\___|___/___/      \n"
  printf "                                                                       \n"
#  printf "                       -------------------------                       \n"
#  printf "                         RUN THIS TOOL AS ROOT                         \n"
#  printf "                       -------------------------                       \n"
#  printf "                                                                       \n"
  printf "                       --= All Pwn Builder =--                         \n"
  printf "           A Mobile Pentesting platform from Pwnie Express             \n"
  printf "                                                                       \n"
  printf " ----------------------------------------------------------------------\n"
  printf "  WARNING: THIS WILL WIPE ALL DATA AND INSTALL PACKAGES ON THE DEVICE. \n"
  printf "  Pwnie Express is not responsible for any damages resulting from the  \n"
  printf "  use of this tool. Backup critical data before continuing.            \n"
  printf " ----------------------------------------------------------------------\n"
  printf "                                                                       \n"

  printf " Boot (n) devices into fastboot mode and continually attach to host machine.\n\n"
  f_pause ' Press [ENTER] to continue, CTRL+C to abort. '
  printf "\n"

# Check for root
#  if [[ $EUID -ne 0 ]]; then
#    printf '\n [!] This tool must be run as root [!]\n\n'
  #exit 1
#  fi

  f_verify_flashables

  # Kill running server
  adb kill-server

  # Start server
  adb start-server


  # Snag serials
  f_getserial
  #get the product
  f_getproduct
  #set pwnie names
  f_setpwnieproduct
  #set flash files
  f_setflashables

  # Get builder
  printf "[!] Enter your initials for the log and press [ENTER] to flash, CTRL+C to abort: "
  read initials

  # Log serials
  f_logserial
}

f_flash() {

  # Unlock bootloader
  printf '\n[+] Unlock the device(s)\n'
  k=0
  while (( $k < $device_count ))
  do
    fastboot oem unlock -s ${serial_array[$k]} 2>&1 > "${DEBUG_FILE}" &
    WAITPIDS="$WAITPIDS "$!
    (( k++ ))
  done
  wait $WAITPIDS
  unset WAITPIDS
  printf '\n...device(s) have been unlocked.\n'

  # Erase boot
  printf '\n[+] Erase boot\n'
  k=0
  while (( $k < $device_count ))
  do
    fastboot erase boot -s ${serial_array[$k]} 2>&1 > "${DEBUG_FILE}" &
    WAITPIDS="$WAITPIDS "$!
    (( k++ ))
  done
  wait $WAITPIDS
  unset WAITPIDS

  # Flash boot
  printf '\n[+] Flash boot\n'
  k=0
  while (( $k < $device_count ))
  do
    if [ "${pwnie_product[$k]}" != "Pwn Pad 3" ]; then
      fastboot flash boot ${image_base[$k]}/boot.img -s ${serial_array[$k]} 2>&1 > "${DEBUG_FILE}" &
      WAITPIDS="$WAITPIDS "$!
    fi
    (( k++ ))
  done
  wait $WAITPIDS
  unset WAITPIDS

  # Flash recovery
  printf '\n[+] Flash recovery\n'
  k=0
  while (( $k < $device_count ))
  do
    fastboot flash recovery ${image_base[$k]}/${recovery[$k]} -s ${serial_array[$k]} 2>&1 > "${DEBUG_FILE}" &
    WAITPIDS="$WAITPIDS "$!
    (( k++ ))
  done
  wait $WAITPIDS
  unset WAITPIDS

  # Format system
  printf '\n[+] Erase and format system\n'
  k=0
  while (( $k < $device_count ))
  do
    fastboot format system -s ${serial_array[$k]} 2>&1 > "${DEBUG_FILE}" &
    WAITPIDS="$WAITPIDS "$!
    (( k++ ))
  done
  wait $WAITPIDS
  unset WAITPIDS

  # Format userdata
  printf '\n[+] Erase and format userdata\n'
  k=0
  while (( $k < $device_count ))
  do
    fastboot format userdata -s ${serial_array[$k]} 2>&1 > "${DEBUG_FILE}" &
    WAITPIDS="$WAITPIDS "$!
    (( k++ ))
  done
  wait $WAITPIDS
  unset WAITPIDS

  # Format cache
  printf '\n[+] Erase and format cache\n'
  k=0
  while (( $k < $device_count ))
  do
    fastboot format cache -s ${serial_array[$k]} 2>&1 > "${DEBUG_FILE}" &
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
	printf "[${pwnie_product[$k]} on ${product_array[$k]}] ${serial_array[$k]} $(date) - $initials\n" | tee -a serial_datetime.txt
	(( k++ ))
  done
}

f_getserial(){

  # Count devices
  device_count="$(fastboot devices |wc -l)"

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
      "Pwn Phone 2014") image_base[$k]="$(pwd)/nexus_5" recovery[$k]="recovery.img" ;;
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
      if [ -d "$i" ]; then
        pushd "$i" 2>&1 > "${DEBUG_FILE}"
        sha512sum --status -c checksums.sha512
        if [ $? = 0 ]; then
          printf "Files in $i are good to go, ready to flash.\n"
        else
          printf "Files in $i are corrupt, unable to flash.\n"
          f_pause "Press enter if you are *sure* you won't be needing the missing/corrupt files or ^C to quit and fix your files"
        fi
        popd 2>&1 > "${DEBUG_FILE}"
      else
        printf "Files to flash $i are missing, unable to flash this device type\n"
        f_pause "Press enter if you are *sure* you won't be needing the missing/corrupt files or ^C to quit and fix your files"
      fi
    done
  fi
}

f_push(){

  # Boot into recovery
  printf '\n[+] Boot into recovery\n'
  k=0
  while (( $k < $device_count ))
  do
    fastboot boot ${image_base[$k]}/${recovery[$k]} -s ${serial_array[$k]} 2>&1 > "${DEBUG_FILE}" &
    WAITPIDS="$WAITPIDS "$!
    (( k++ ))
  done
  wait $WAITPIDS
  unset WAITPIDS

  k=0
  while (( $k < $device_count ))
  do
    sleepy_time[$k]=0
    while ! adb -s ${serial_array[$k]} shell true 2>&1 > "${DEBUG_FILE}"; do
      sleep 1
      (( sleepy_time[$k]++ ))
      printf "Waiting on ${serial_array[$k]} to boot recovery for ${sleepy_time[$k]} seconds.\n"
    done
    (( k++ ))
  done

  # Push backup to be restored
  printf '\n[+] Push backup\n'
  k=0
  while (( $k < $device_count ))
  do
    adb -s ${serial_array[$k]} push ${image_base[$k]}/TWRP/ /data/media/0/TWRP/ 2>&1 > "${DEBUG_FILE}" &
    WAITPIDS="$WAITPIDS "$!
    (( k++ ))
  done
  wait $WAITPIDS
  unset WAITPIDS

  # Write serial number to backup directory
  k=0
  while (( $k < $device_count ))
  do
    adb -s ${serial_array[$k]} shell "mv /data/media/0/TWRP/BACKUPS/serial/ /data/media/0/TWRP/BACKUPS/${serial_array[$k]}" 2>&1 > "${DEBUG_FILE}" &
    WAITPIDS="$WAITPIDS "$!
    (( k++ ))
  done
  wait $WAITPIDS
  unset WAITPIDS

  # Push backgrounds
  k=0
  while (( $k < $device_count ))
  do
    if [ "${pwnie_product[$k]}" != "Pwn Pad 3" ]; then
      adb -s ${serial_array[$k]} push TWRP/sdcard/ /sdcard/ 2>&1 > "${DEBUG_FILE}" &
      WAITPIDS="$WAITPIDS "$!
    fi
    (( k++ ))
  done
  wait $WAITPIDS
  unset WAITPIDS
}

f_setup(){
  # Create script for restore and chroot setup
  k=0
  while (( $k < $device_count ))
  do
# Construct cmd for script
    backup=$(ls ${image_base[$k]}/TWRP/BACKUPS/* |grep -i pwn)
    adb -s ${serial_array[$k]} shell "
    cat << EOF > /cache/recovery/openrecoveryscript
restore /data/media/0/TWRP/BACKUPS/${serial_array[$k]}/$backup
print  [SETUP STARTED]
cmd export PATH=/usr/bin:/usr/sbin:/bin:/usr/local/bin:/usr/local/sbin:$PATH
cmd mount -o bind /dev /data/local/kali/dev
cmd chroot /data/local/kali/ /bin/dd if=/dev/zero of=/kali.img bs=1 count=0 seek=4G;chroot /data/local/kali/ /sbin/mkfs.ext4 -F /kali.img
cmd mv /data/local/kali/kali.img /data/local/kali_img/;mkdir /data/local/kali_img/kali-tmp;mount -t ext4 /data/local/kali_img/kali.img /data/local/kali_img/kali-tmp/;cp -a /data/local/kali/* /data/local/kali_img/kali-tmp/;umount /data/local/kali_img/kali-tmp/;rm -r /data/local/kali_img/kali-tmp
print  [SETUP COMPLETE]
EOF
    "
    (( k++ ))
  done

  # Reboot into recovery to run script
  printf '\n[+] Reboot into recovery\n'
  printf '\n Restoring...\n'
  printf '\n After the target backup has been restored, the Kali chroot environment must be setup.\n'
  printf '\n Do not power off the device during this time.\n'
  printf '\n[!] When the device has rebooted into the system, the build is complete.\n\n'
  k=0
  while (( $k < $device_count ))
  do
    adb -s ${serial_array[$k]} reboot recovery 2>&1 > "${DEBUG_FILE}" &
    WAITPIDS="$WAITPIDS "$!
    (( k++ ))
  done
  wait $WAITPIDS
  unset WAITPIDS

}

f_cleanup() {
  adb kill-server 2>&1 > "${DEBUG_FILE}"
}

f_run
f_flash
f_push
f_setup
f_cleanup

##Continuous rewrite structure
#drop all output, create desired output
#trap all exit codes, ensure success before moving on
#report failure
#log after SUCCESSFUL flash only

#psuedo code
#setup stuff
#f_run
#prompt to run f_verify_flashables
#  welcome, ask for initials, crap work

#main runners
#f_feedme
  #this is the main look, so likely read some global variable for status
  #simple like "$serial - $currentstate"
#f_getserial
#  this constantly looks for new devices, adds their serial to the queue
# do basic information gathering on the device before flash begins
#f_getproduct
#f_setpwnieproduct
#f_setflashables

#now we have enough info, pop off the queue and burn it
#spin it off into the background let it go
#f_flash
#f_push
#f_setup
