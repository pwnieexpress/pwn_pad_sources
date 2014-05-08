#!/system/bin/sh
# Description: Factory resets the Pwn Pad 2013/2014 and Pwn Phone 2014 
# Result: Stock Pwn Pad 2013/2014 or Pwn Phone 2014
# Author: t1mz0r
# Company: Pwnie Express
# Contact: tim@pwnieexpress.com

f_run(){

  clear
  echo
  echo '[!] FACTORY RESET in progress. All changes will be lost.'
  echo

  f_reset
}

f_getserial(){

  # Snag serial
  serialno=`getprop ro.serialno`
}

f_getstorage(){

  # Set backup
  backup=`ls TWRP/BACKUPS/$serialno/* |grep -i phone`

  # Get storage size
  storagesi=`dumpsys devicestoragemonitor |grep mTotalMemory |cut -d "=" -f3 |cut -d "." -f1`

  # Set seek size
  if (( storagesi > 20 )); then # 32G [~26G free]
    # Set seek size to 20G
    seeksi=20
  elif (( storagesi > 8 )); then #16G [~9G free]
    # Set seek size to 7G
    seeksi=7
  else # 8G [~?G free]
    # Set seek size to ?G
    seeksi=4
  fi
}

f_reset(){

  # CANNOT USE [*] FOR SERIAL NUMBER OR BACKUP
  f_getserial
  f_getstorage

  # Construst cmd for script
  echo -e 'restore /data/media/0/TWRP/BACKUPS/'$serialno'/'$backup'\ncmd export PATH=/usr/bin:/usr/sbin:/bin:/usr/local/bin:/usr/local/sbin:$PATH\nprint  [SETUP STARTED]\ncmd chroot /data/local/kali/ /bin/dd if=/dev/zero of=/kali.img bs=1 count=0 seek='$seeksi'G;chroot /data/local/kali/ /sbin/mkfs.ext4 -F /kali.img\ncmd mv /data/local/kali/kali.img /data/local/kali_img/;mkdir /data/local/kali_img/kalitmp;mount -t ext4 /data/local/kali_img/kali.img /data/local/kali_img/kalitmp/;cp -a /data/local/kali/* /data/local/kali_img/kalitmp/;rm -r /data/local/kali/*;umount /data/local/kali_img/kalitmp/;rm -r /data/local/kali_img/kalitmp\nprint  [SETUP COMPLETE]\nprint  [FACTORY RESET COMPLETE]' > /cache/recovery/openrecoveryscript

  # Reboot into recovery; run script
  reboot recovery
}

f_run
