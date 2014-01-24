#/bin/bash

f_banner(){
  clear
  echo "Pwn Pad Update"
  echo "Warning, this update will overwrite any modified config files !"
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
    echo "[+] Congratulations your Pad has been updated!"
  else
    echo "[-] Update cancelled."
    echo "[-] Exiting."
  fi
}

f_banner
f_confirm_and_do_update
