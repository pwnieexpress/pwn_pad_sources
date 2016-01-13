# /bin/bash
#script to update mobile line using standard chef update procedure
#set the prompt to the name of the script
PS1=${PS1//@\\h/@update}
clear

. /opt/pwnix/pwnpad-scripts/px_functions.sh

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

f_confirm_and_do_update(){
  if [ $(f_one_or_two) -eq 1 ]; then
    printf "Starting update...\n"
    /opt/pwnix/chef/update.sh
    printf "\n[!] Congratulations, this device has been updated!\n"
    printf "The current version is:\n"
    grep -Ei "release (version|date)" /etc/motd
    printf "[!] Reboot for the update to take effect!\n\n"
  else
    printf "Update cancelled.\n"
    printf "Exiting.\n"
    return 1
  fi
}

f_banner
f_confirm_and_do_update
