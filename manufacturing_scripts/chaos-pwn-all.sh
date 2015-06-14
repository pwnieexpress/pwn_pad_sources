#!/bin/bash
# Target: All Pwnie Express officially supported mobile devices
# Action: Unlocks bootloader, flashes custom boot and recovery, then restores backup and sets up chroot environment
# Result: Pwnify all
# Author: t1mz0r tim@pwnieexpress.com
# Author: Zero_Chaos zero@pwnieexpress.com
# Company: Pwnie Express

f_pause(){
  read -p "$*"
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
    echo
    echo ' [!] This tool must be run as root [!]'
    echo
  #exit 1
  fi

  # Kill running server
  killall adb &> /dev/null

  # Start server
  adb start-server
  echo

  # Snag serials
  f_getserial
  #get the product
  f_getproduct
  #set pwnie names
  f_setpwnieproduct
  #set flash files
  f_setflashables
  echo

  # Get builder
  read -p '[!] Enter your initials for the log and press [ENTER] to flash, CTRL+C to abort: ' initials

  # Log serials
  f_logserial
}

f_flash() {

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

  # Erase boot
  echo
  echo '[+] Erase boot'
  k=0
  while (( $k < $device_count ))
  do
    fastboot erase boot -s ${serial_array[$k]} &
    WAITPIDS="$WAITPIDS "$!
    (( k++ ))
  done
  wait $WAITPIDS
  unset WAITPIDS

  # Flash boot
  echo
  echo '[+] Flash boot'
  k=0
  while (( $k < $device_count ))
  do
    if [ "${pwnie_product[$k]}" != "Pwn Pad 3" ]; then
      fastboot flash boot ${image_base[$k]}/boot.img -s ${serial_array[$k]} &
      WAITPIDS="$WAITPIDS "$!
    fi
    (( k++ ))
  done
  wait $WAITPIDS
  unset WAITPIDS

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

  # Format system
  echo
  echo '[+] Erase and format system'
  k=0
  while (( $k < $device_count ))
  do
    fastboot format system -s ${serial_array[$k]} &
    WAITPIDS="$WAITPIDS "$!
    (( k++ ))
  done
  wait $WAITPIDS
  unset WAITPIDS

  # Format userdata
  echo
  echo '[+] Erase and format userdata'
  k=0
  while (( $k < $device_count ))
  do
    fastboot format userdata -s ${serial_array[$k]} &
    WAITPIDS="$WAITPIDS "$!
    (( k++ ))
  done
  wait $WAITPIDS
  unset WAITPIDS

  # Format cache
  echo
  echo '[+] Erase and format cache'
  k=0
  while (( $k < $device_count ))
  do
    fastboot format cache -s ${serial_array[$k]} &
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
	echo "[${pwnie_product[$k]} on ${product_serial[$k]}] ${serial_array[$k]} $(date) - $initials" | tee -a serial_datetime.txt
	(( k++ ))
  done
}

f_getserial(){

  # Count devices
  device_count=`fastboot devices |wc -l`

  # Store serials
  i=0
  while read line
  do
   	serial_array[$i]="$line"
   	(( i++ ))
  done < <(fastboot devices | awk '{print $1}')

  # Print devices
  if (( $device_count > 1 ))
  then
	echo "There are $device_count 'devices connected"
  else
	echo "There is 1 device connected:"
  fi
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
    case "${pwnie_product[$k]}" in
      "Pwn Pad 2013") image_base[$k]="/home/zero/manuf_images/nexus_2012" recovery[$k]="twrp-2.8.6.0-grouper.img" ;;
      "Pwn Pad 2014") image_base[$k]="/home/zero/manuf_images/nexus_2013" recovery[$k]="openrecovery-twrp-2.6.3.0-deb.img" ;;
      "Pwn Phone 2014") image_base[$k]="/home/zero/manuf_images/nexus_5" recovery[$k]="recovery.img" ;;
      "Pwn Pad 3") image_base[$k]="/home/zero/manuf_images/shield-tablet" recovery[$k]="twrp-2.8.6.0-shieldtablet.img" ;;
      *) printf "Unknown flashables ${pwnie_product[$k]}\n"; exit 1 ;;
    esac
    (( k++ ))
  done
}

f_push(){

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
  sleep 20

  # Reboot into recovery to mitigate boot chain error
  #echo '[+] Reboot into recovery'
  #k=0
  #while (( $k < $device_count ))
  #do
  #	adb -s ${serial_array[$k]} reboot recovery &
  #	(( k++ ))
  #done
  #wait
  #sleep 20

  # Push backup to be restored
  echo
  echo '[+] Push backup'
  k=0
  while (( $k < $device_count ))
  do
    adb -s ${serial_array[$k]} push ${image_base[$k]}/TWRP/ /data/media/0/TWRP/ &
    WAITPIDS="$WAITPIDS "$!
    (( k++ ))
  done
  wait $WAITPIDS
  unset WAITPIDS
  sleep 2

  # Write serial number to backup directory
  k=0
  while (( $k < $device_count ))
  do
    adb -s ${serial_array[$k]} shell "mv /data/media/0/TWRP/BACKUPS/serial/ /data/media/0/TWRP/BACKUPS/${serial_array[$k]}" &
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
      adb -s ${serial_array[$k]} push TWRP/sdcard/ /sdcard/ &
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
    backup=`ls ${image_base[$k]}/TWRP/BACKUPS/* |grep -i pwn`
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
  echo
  echo '[+] Reboot into recovery'
  echo
  echo ' Restoring...'
  echo
  echo ' After the target backup has been restored, the Kali chroot environment must be setup.'
  echo
  echo ' Do not power off the device during this time.'
  echo
  echo '[!] When the device has rebooted into the system, the build is complete.'
  echo
  k=0
  while (( $k < $device_count ))
  do
    adb -s ${serial_array[$k]} reboot recovery &
    WAITPIDS="$WAITPIDS "$!
    (( k++ ))
  done
  wait $WAITPIDS
  unset WAITPIDS

}

f_run
f_flash
f_push
f_setup
