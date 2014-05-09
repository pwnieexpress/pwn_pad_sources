# /bin/bash
# Script to copy captures folder to USB drive attached to PwnPad via OTG cable

f_banner(){
  clear
  echo "This script will mount a USB drive attached via OTG and copy the /opt/pwnix/captures/ folder to the USB drive mounted at /usb-otg/"
  echo
  echo "[?] Copy captures folder to usb drive?"
  echo
  echo "[!] This will overwrite any pre-existing captures folder on the drive!"
  echo
  echo "Do you want to continue?"
  echo
  echo "1. Yes"
  echo "2. No"
  echo

  read -p "Choice [1 or 2]: " input
  case $input in
    1) proceed=1 ;;
    2) proceed=2 ;;
    *) f_banner ;;
  esac
}

# Mount USB drive and copy captures folder to drive
f_mount_cp(){
  if [ $proceed -eq 1 ]; then
    if [ -x /usb-otg ]; then
      echo 
    else
      mkdir /usb-otg
    fi
    echo
    echo "[+] Mounting USB drive to /usb-otg/.."
    mount /dev/block/sda1 /usb-otg/
    echo
    echo "[!] ..Done"
    echo
    echo "[+] Copying captures directory..."
    echo
    cp -a /opt/pwnix/captures/ /usb-otg/
    echo
    echo "[!] ..Done"
    echo
    f_umount
  else
    echo "[-] Not mounting or copying captures folder"
    echo "[-] Exiting"
  fi
}

# Umount USB drive
f_umount(){

  echo
  echo
  echo "Do you want to un-mount attached USB drive?"
  echo
  echo "1. Yes"
  echo "2. No"
  echo
  read -p "Choice [1 or 2]: " input2
  case $input2 in
    1) unmount=1 ;;
    2) unmount=2 ;;
    *) f_umount ;;
  esac

  if [ $unmount -eq 1 ]; then
    umount /usb-otg/
    rm -r /usb-otg/
    echo 
    echo "[-] USB Drive has been un-mounted and is safe to remove"
    echo "[-] Exiting"
  else
    echo "[!] USB drive still mounted to /usb-otg/"
    echo "[!] Unmount manually with: umount /usb-otg"
    echo "[-] Exiting"
  fi
}

f_banner
f_mount_cp
