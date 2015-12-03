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

# Construct cmd for script
rm -f /cache/recovery/openrecoveryscript
[ "$chroot_only" = "0" ] && printf "restore /data/media/0/TWRP/BACKUPS/$serialno/$backup\n" > /cache/recovery/openrecoveryscript
cat << EOF >> /cache/recovery/openrecoveryscript
print  [SETUP STARTED]
cmd export PATH=/system/xbin:/system/bin:$PATH
EOF
if [-f /data/local/kali_img/stockchroot.sfs ]; then
  chroot_file="/data/local/kali_img/stockchroot.sfs"
  chroot_version="2"
  mount_command="cmd busybox mount -t squashfs /data/local/kali_img/stockchroot.sfs /data/local/kali_img/kalitmp"
elif [ -f /data/local/kali_img/stockchroot.img ]; then
  chroot_file="/data/local/kali_img/stockchroot.img"
  chroot_version="1"
  mount_command="cmd busybox mount -t ext4 /data/local/kali_img/stockchroot.img /data/local/kali_img/kalitmp"
fi

if [ -n "${chroot_file}" ]; then
  #if we have a stockchroot.{img,sfs}, use it and remove the old version
  if [ -f /data/local/kali_img/kali.img ]; then
    rm -f /data/local/kali_img/kali.img
  fi

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

  #we have stockchroot.img, that means we kill /data/local/kali and unpack there
  cat << EOF >> /cache/recovery/openrecoveryscript
print  [ Restoring v${chroot_version} chroot ]
cmd busybox rm -r /data/local/kali/*
cmd busybox mkdir /data/local/kali_img/kalitmp
${mount_command}
cmd cp -a /data/local/kali_img/kalitmp/* /data/local/kali
cmd busybox umount /data/local/kali_img/kalitmp
cmd busybox rm -r /data/local/kali_img/kalitmp
cmd busybox echo "$PRODUCT" > /data/local/kali/etc/product
cmd busybox echo "$product" > /data/local/kali/etc/hostname
cmd busybox sed -i "s/127\.0\.0\.1.*/127.0.0.1       $product localhost/" /data/local/kali/etc/hosts
EOF
else
  #we do not have stockchroot.{img,sfs}, that means we are on v0
  cat << EOF >> /cache/recovery/openrecoveryscript
print  [ Restoring v0 chroot ]
cmd busybox mount -o bind /dev /data/local/kali/dev
cmd busybox chroot /data/local/kali/ /bin/dd if=/dev/zero of=/kali.img bs=1 count=0 seek=4G
cmd busybox chroot /data/local/kali/ /sbin/mkfs.ext4 -F /kali.img
cmd busybox umount /data/local/kali/dev
cmd busybox mv /data/local/kali/kali.img /data/local/kali_img/
cmd busybox mkdir /data/local/kali_img/kalitmp
cmd busybox mount -t ext4 /data/local/kali_img/kali.img /data/local/kali_img/kalitmp/
cmd cp -a /data/local/kali/* /data/local/kali_img/kalitmp/
cmd busybox umount /data/local/kali_img/kalitmp/
cmd busybox rm -r /data/local/kali_img/kalitmp
EOF
fi
cat << EOF >> /cache/recovery/openrecoveryscript
print  [SETUP COMPLETE]
print  [FACTORY RESET COMPLETE]
EOF

# Reboot into recovery; run script
reboot recovery
