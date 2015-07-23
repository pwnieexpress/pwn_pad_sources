#!/system/bin/sh
# Description: Factory resets Pwn Pad 2013/2014 and Pwn Phone 2014
# Result: Stock Pwn Pad 2013/2014/3 or Pwn Phone 2014
#set the prompt to the name of the script
PS1=${PS1//@\\h/@FACTORY_RESET}
clear

#Blank everything by default, but allow to blank only some
: ${chroot_only:=0}

# Snag serial
serialno=$(/system/bin/getprop ro.serialno)

# Set backup
backup=$(ls /sdcard/TWRP/BACKUPS/$serialno/ |grep -i pwn)

# Construst cmd for script
rm -f /cache/recovery/openrecoveryscript
[ "$chroot_only" = "0" ] && printf "restore /data/media/0/TWRP/BACKUPS/$serialno/$backup\n" > /cache/recovery/openrecoveryscript
cat << EOF >> /cache/recovery/openrecoveryscript
print  [SETUP STARTED]
cmd export PATH=/system/xbin:/system/bin:$PATH
EOF
if [ -f /data/local/kali_img/kali.img ]; then
  rm -f /data/local/kali_img/kali.img
fi
if [ ! -f /data/local/kali_img/stockchroot.img ]; then
  #we do not have stockchroot.img, that means we are migrating from v0 to v1
  cat << EOF >> /cache/recovery/openrecoveryscript
print  [ Converting v0 chroot to v1 chroot ]
cmd busybox dd if=/dev/zero of=/data/local/kali_img/stockchroot.img bs=1 count=0 seek=2047M
cmd busybox /sbin/mkfs.ext2 -F /data/local/kali_img/stockchroot.img
cmd busybox mkdir /data/local/kali_img/kalitmp
cmd busybox mount -t ext4 /data/local/kali_img/stockchroot.img /data/local/kali_img/kalitmp/
cmd busybox cp -a /data/local/kali/* /data/local/kali_img/kalitmp/
cmd busybox umount /data/local/kali_img/kalitmp/
cmd busybox rm -r /data/local/kali_img/kalitmp
EOF
else
  #we have stockchroot.img, that means we kill /data/local/kali and unpack there

  #support any chroot to restore from, adjust product as needed
  PRODUCT=$(cat /data/local/kali/etc/product)
  if [ "${PRODUCT}" = "Pwn Pad" ]; then
    product="pwnpad"
  elif [ "${PRODUCT}" = "Pwn Phone 2014" ]; then
    product="pwnphone"
  else
    PRODUCT="unknown"
    product="unknown"
  fi

  cat << EOF >> /cache/recovery/openrecoveryscript
print  [ Restoring v1 chroot ]
cmd busybox rm -r /data/local/kali/*
cmd busybox mkdir /data/local/kali_img/kalitmp
cmd busybox mount -t ext4 /data/local/kali_img/stockchroot.img /data/local/kali_img/kalitmp
cmd busybox cp -a /data/local/kali_img/kalitmp/* /data/local/kali
cmd busybox umount /data/local/kali_img/kalitmp
cmd busybox rm -r /data/local/kali_img/kalitmp
cmd busybox echo "$PRODUCT" > /data/local/kali/etc/product
cmd busybox echo "$product" > /data/local/kali/etc/hostname
cmd busybox sed -i "s/127\.0\.0\.1.*/127.0.0.1       $product localhost/" /data/local/kali/etc/hosts
EOF
fi
cat << EOF >> /cache/recovery/openrecoveryscript
print  [SETUP COMPLETE]
print  [FACTORY RESET COMPLETE]
EOF

# Reboot into recovery; run script
reboot recovery
