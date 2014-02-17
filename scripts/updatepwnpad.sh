# /bin/bash

f_banner(){
  clear
  echo "Pwn Pad Update"
  echo "Warning, this update will overwrite any modified config files !"
  echo
  echo "Please note that this will start the Pwnie UI and SSHD services if they"
  echo "are not running. Please stop those services after the update if you do not"
  echo "want them to be running."
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
  read -p "Choice (1 or 2): " input
  case $input in
    [1-2]*) echo $input ;;
    *)
      f_one_or_two
      ;;
  esac
}

f_confirm_and_do_update(){
  if [ $(f_one_or_two) -eq 1 ]; then
    echo "[+] Starting Update..."
    /opt/pwnix/chef/update.sh
    echo
    echo "[+] Congratulations your PwnPad has been updated!"
    echo "[+] The current version is:"
    grep -Ei "release (version|date)" /etc/motd
    echo "[!] Please reboot this devices for the update to take effect."
    echo "[!] Note: if an icon dissapears from your desktop it means that the app has been updated. Please re-add these apps from the main Android app menu."
  else
    echo "[-] Update cancelled."
    echo "[-] Exiting."
  fi
}

f_banner
f_confirm_and_do_update
