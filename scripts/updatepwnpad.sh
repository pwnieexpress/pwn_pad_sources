# /bin/bash
#script to update mobile line using standard chef update procedure
clear

f_banner(){
  printf "\n[!] WARNING: This will overwrite any modified config files!\n\n"
  printf "[+] This will start the Pwnie UI and SSHD services.\n"
  printf "[-] Please stop those services after the update if you do not want them to be running.\n\n"
  printf "The current version is:\n"
  grep -Ei "release (version|date)" /etc/motd
  printf "\n"
  printf "Do you want to continue?\n\n"
  printf "1. Yes\n"
  printf "2. No\n\n"
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
    /opt/pwnix/chef/update.sh
    echo
    echo "[!] Congratulations, this device has been updated!"
    echo "The current version is:"
    grep -Ei "release (version|date)" /etc/motd
    echo "[!] Reboot for the update to take effect!"
    echo
  else
    echo "Update cancelled."
    echo "Exiting."
    exit 1
  fi
}

f_banner
f_confirm_and_do_update
