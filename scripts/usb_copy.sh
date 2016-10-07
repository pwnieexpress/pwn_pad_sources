# /bin/bash
# Script to copy captures folder to USB drive attached to PwnPad via OTG cable
# Set the prompt to the name of the script
PS1=${PS1//@\\h/@usb_copy}
clear

f_checkforusb(){
  if [ ! -b /dev/block/sda1 ]; then
    printf "\nPlease insert a usb stick before running this script.\n"
    return 1
  fi
}

f_banner(){
  printf "\nThis script will mount a USB drive attached via OTG and copy the /opt/pwnix/captures/ folder to the USB drive mounted at /usb-otg/\n\n"
  printf "[?] Copy captures folder to usb drive?\n\n"
  printf "[!] This will overwrite any pre-existing captures folder on the drive!\n\n"
  printf "Do you want to continue?\n\n"
  printf "1. Yes\n"
  printf "2. No\n\n"

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
      printf "\n"
    else
      mkdir /usb-otg
    fi
    printf "\n[+] Mounting USB drive to /usb-otg/..\n"
    mount /dev/block/sda1 /usb-otg/
    printf "\n[!] ..Done\n\n"
    printf "[+] Copying captures directory...\n\n"
    cp -R /opt/pwnix/captures/ /usb-otg/
    printf "\n[!] ..Done\n\n"
    f_umount
  else
    printf "[-] Not mounting or copying captures folder\n"
    printf "[-] Exiting\n"
  fi
}

# Umount USB drive
f_umount(){

  printf "\n\nDo you want to un-mount attached USB drive?\n\n"
  printf "1. Yes\n"
  printf "2. No\n\n"
  read -p "Choice [1 or 2]: " input2
  case $input2 in
    1) unmount=1 ;;
    2) unmount=2 ;;
    *) f_umount ;;
  esac

  if [ $unmount -eq 1 ]; then
    umount /usb-otg/
    rm -r /usb-otg/
    printf "\n[-] USB Drive has been un-mounted and is safe to remove\n"
    printf "[-] Exiting\n"
  else
    printf "[!] USB drive still mounted to /usb-otg/\n"
    printf "[!] Unmount manually with: umount /usb-otg\n"
    printf "[-] Exiting\n"
  fi
}

f_checkforusb
if [ $? = 0 ]; then
  f_banner
  f_mount_cp
fi
