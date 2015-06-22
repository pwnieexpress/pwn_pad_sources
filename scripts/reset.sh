#!/system/bin/sh
# Description: Factory resets Pwn Pad 2013/2014 and Pwn Phone 2014
# Result: Stock Pwn Pad 2013/2014/3 or Pwn Phone 2014
clear

#Blank everything by default, but allow to blank only some
: ${chroot_only:=0}

printf '\n[!] FACTORY RESET in progress. All changes will be lost.\n\n'

# Snag serial
serialno=`/system/bin/getprop ro.serialno`

# Set backup
backup=`ls /sdcard/TWRP/BACKUPS/$serialno/ |grep -i pwn`

# Construst cmd for script
rm -f /cache/recovery/openrecoveryscript
[ "$chroot_only" = 0 ] && printf "restore /data/media/0/TWRP/BACKUPS/$serialno/$backup\n" > /cache/recovery/openrecoveryscript
cat << EOF >> /cache/recovery/openrecoveryscript
print  [SETUP STARTED]
cmd export PATH=/usr/bin:/usr/sbin:/bin:/usr/local/bin:/usr/local/sbin:$PATH
cmd mount -o bind /dev /data/local/kali/dev
cmd chroot /data/local/kali/ /bin/dd if=/dev/zero of=/kali.img bs=1 count=0 seek=4G
cmd chroot /data/local/kali/ /sbin/mkfs.ext4 -F /kali.img
cmd mv /data/local/kali/kali.img /data/local/kali_img/
cmd mkdir /data/local/kali_img/kalitmp
cmd mount -t ext4 /data/local/kali_img/kali.img /data/local/kali_img/kalitmp/
cmd cp -a /data/local/kali/* /data/local/kali_img/kalitmp/
cmd umount /data/local/kali_img/kalitmp/
cmd rm -r /data/local/kali_img/kalitmp
print  [SETUP COMPLETE]
print  [FACTORY RESET COMPLETE]
EOF

# Reboot into recovery; run script
reboot recovery
