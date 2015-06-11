#!/bin/bash
# Target: Nexus 7 (deb/flo)
# Action: Unlocks bootloader, flashes custom boot and recovery, then restores backup and sets up chroot environment
# Result: Pwn Pad 2014
# Author: t1mz0r
# Company: Pwnie Express
# Contact: tim@pwnieexpress.com

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
  echo "                       --= Pwn Pad Builder =--                         "
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
  exit 1
  fi

  # Kill running server
  killall adb &> /dev/null

  # Start server
  adb start-server
  echo

  # Snag serials
  f_getserial
  echo

  # Get builder
  read -p '[!] Enter your initials for the log and press [ENTER] to flash, CTRL+C to abort: ' initials
}

f_flash() {

  # Log serials
  f_logserial

  # Unlock bootloader
  echo
  echo '[+] Unlock the device(s)'
  k=0
  while (( $k < $device_count ))
  do
    fastboot oem unlock -s ${serial_array[$k]} &
	(( k++ ))
  done
  wait
  echo
  echo '...device(s) have been unlocked.'

  # Erase boot
  echo
  echo '[+] Erase boot'
  k=0
  while (( $k < $device_count ))
  do
	fastboot erase boot -s ${serial_array[$k]} &
	(( k++ ))
  done
  wait

  # Flash boot
  echo
  echo '[+] Flash boot'
  k=0
  while (( $k < $device_count ))
  do
	fastboot flash boot boot.img -s ${serial_array[$k]} &
	(( k++ ))
  done
  wait

  # Flash recovery
  echo
  echo '[+] Flash recovery'
  k=0
  while (( $k < $device_count ))
  do
	fastboot flash recovery recovery.img -s ${serial_array[$k]} &
	(( k++ ))
  done
  wait

  # Format system
  echo
  echo '[+] Erase and format system'
  k=0
  while (( $k < $device_count ))
  do
	fastboot format system -s ${serial_array[$k]} &
	(( k++ ))
  done
  wait

  # Format userdata
  echo
  echo '[+] Erase and format userdata'
  k=0
  while (( $k < $device_count ))
  do
	fastboot format userdata -s ${serial_array[$k]} &
	(( k++ ))
  done
  wait
}

f_logserial(){

  # Snag serials again in case additional devices have been attached
  f_getserial &> /dev/null

  # Get time
  f_timestamp

  # Log serials
  k=0
  while (( $k < $device_count ))
  do
	echo ${serial_array[$k]} >> serial_log.txt
	echo ${serial_array[$k]} $time - $initials >> serial_datetime.txt
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
  done < <(fastboot devices |cut -c 1-8)

  # Print devices
  if (( $device_count > 1 ))
  then
	echo 'There are' $device_count 'devices connected: '
  else
	echo 'There is 1 device connected: '
  fi
  fastboot devices
}

f_timestamp(){

  # Get time
  time=`date`
}

f_push(){

  # Boot into recovery
  echo
  echo '[+] Boot into recovery'
  k=0
  while (( $k < $device_count ))
  do
	fastboot boot recovery.img -s ${serial_array[$k]} &
	(( k++ ))
  done
  wait
  sleep 9

  # Reboot into recovery to mitigate boot chain error
  echo
  echo '[+] Reboot into recovery'
  k=0
  while (( $k < $device_count ))
  do
	adb -s ${serial_array[$k]} reboot recovery &
	(( k++ ))
  done
  wait
  sleep 20

  # Push backup to be restored
  echo
  echo '[+] Push backup'
  k=0
  while (( $k < $device_count ))
  do
	adb -s ${serial_array[$k]} push TWRP/ /data/media/0/TWRP/ &
	(( k++ ))
  done
  wait
  sleep 2

  # Write serial number to backup directory
  k=0
  while (( $k < $device_count ))
  do
	adb -s ${serial_array[$k]} shell "mv /data/media/0/TWRP/BACKUPS/serial/ /data/media/0/TWRP/BACKUPS/${serial_array[$k]}" &
	(( k++ ))
  done
  wait

  # Push backgrounds
  k=0
  while (( $k < $device_count ))
  do
  adb -s ${serial_array[$k]} push TWRP/sdcard/ /sdcard/ &
  (( k++ ))
  done
  wait
}

f_setup(){

  # Create script for restore and chroot setup
  backup=`ls TWRP/BACKUPS/* |grep Pwn`
  k=0
  while (( $k < $device_count ))
  do
	# Note: need double space before print cmd value in order to insert blank \n after
	adb -s ${serial_array[$k]} shell "echo -e 'restore /data/media/0/TWRP/BACKUPS/${serial_array[$k]}/$backup\ncmd export PATH=/usr/bin:/usr/sbin:/bin:/usr/local/bin:/usr/local/sbin:$PATH\nprint  [SETUP STARTED]\ncmd chroot /data/local/kali/ /bin/dd if=/dev/zero of=/kali.img bs=1 count=0 seek=20G;chroot /data/local/kali/ /sbin/mkfs.ext4 -F /kali.img\ncmd mv /data/local/kali/kali.img /data/local/kali_img/;mkdir /data/local/kali_img/kalitmp;mount -t ext4 /data/local/kali_img/kali.img /data/local/kali_img/kalitmp/;cp -a /data/local/kali/* /data/local/kali_img/kalitmp/;rm -r /data/local/kali/*;umount /data/local/kali_img/kalitmp/;rm -r /data/local/kali_img/kalitmp\nprint  [SETUP COMPLETE]\nprint  [FACTORY RESET COMPLETE]' > /cache/recovery/openrecoveryscript" &
	(( k++ ))
  done
  wait

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
	(( k++ ))
  done
  wait
}

f_run
f_flash
f_push
f_setup
