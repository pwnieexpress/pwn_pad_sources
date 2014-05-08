# /bin/bash

f_banner(){
  clear
  echo "[!] WARNING: This will overwrite any modified config files!"
  echo
  echo "[+] This will start the Pwnie UI and SSHD services."
  echo "[-] Please stop those services after the update if you do not want them to be running."
  echo
  echo "The current version is:"
  grep -Ei "release (version|date)" /etc/motd
  echo
  echo "Do you want to continue?"
  echo
  echo "1. Yes"
  echo "2. No"
  echo
}

f_one_or_two(){
  read -p "Choice [1 or 2]: " input
  case $input in
    [1-2]*) echo $input ;;
    *)
      f_one_or_two
      ;;
  esac
}

f_confirm_and_do_update(){
  if [ $(f_one_or_two) -eq 1 ]; then
    echo "Starting update..."
    # If /system is mounted ro then mount rw for update then mount back
    # Avoid having /system mounted rw
    if [ ! -w /system ]; then
      local remount=yes
      mount -o rw,remount /system
  fi
    /opt/pwnix/chef/update.sh
    if [ "remount" = "yes" ]; then
      mount -o ro,remount /system
    fi
    echo
    echo "[!] Congratulations, this device has been updated!"
    echo "The current version is:"
    grep -Ei "release (version|date)" /etc/motd
    echo "[!] Reboot for the update to take effect!"
    echo
    echo "[!] If an app disappears from the home screen, then that app has been updated."    echo "[+] You can re-add it from the app drawer."
  else
    echo "Update cancelled."
    echo "Exiting."
    exit 1
  fi
}

f_banner
f_confirm_and_do_update
