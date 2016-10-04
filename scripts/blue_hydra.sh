#!/bin/bash
# Bluetooth scanning / logging script using bluelog
#set the prompt to the name of the script
PS1=${PS1//@\\h/@blue_hydra}
clear

bluetooth=1
. /opt/pwnix/pwnpad-scripts/px_functions.sh

f_intbh(){
   pkill -f '/bin/blue_hydra'
   printf "\nBlue_Hydra process killed...\n"
   f_endsummary
}

f_cleanup(){
  printf "\nStopping Services...\n"
  service bluetooth stop
  service dbus stop
  exit 1
}

f_endsummary() {
  clear
  printf "\n[-] Blue_Hydra db file saved to /opt/pwnix/data/blue_hydra/blue_hydra.db\n\n"
  if [ "${save}" = "1" ]; then
    STOP_TIME=$(date +"%s")
    QUERY=$(cat <<EOF
SELECT address, vendor, company, manufacturer, 
       classic_mode AS classic, 
       le_mode AS le, le_address_type, 
       updated_at as last_seen,
       classic_major_class, classic_minor_class, classic_class 
FROM blue_hydra_devices 
WHERE CAST(strftime('%s',updated_at) AS integer) 
BETWEEN CAST($START_TIME AS integer) AND CAST($STOP_TIME AS integer);
EOF
)

    echo $QUERY | sqlite3 -header -column /opt/pwnix/data/blue_hydra/blue_hydra.db > $FILENAME
    printf "\n[-] Blue_Hydra summary saved to $FILENAME\n\n"
  fi
  cd /opt/pwnix/captures/bluetooth
  f_cleanup
}

f_savecap() {
  printf "\nSave packet capture to /opt/pwnix/captures/bluetooth/ ?\n\n"
  printf "1. Yes\n"
  printf "2. No\n\n"
  read -p "Choice: " saveyesno

  case $saveyesno in
    1) save=1 ;;
    2) save=0 ;;
    *) f_savecap ;;
  esac
}

if loud_one=1 f_validate_one hci0; then
  f_savecap
  hciconfig hci0 up
  service dbus status || service dbus start
  service bluetooth status || service bluetooth start
  clear
  START_TIME=$(date +"%s")
  FILENAME=/opt/pwnix/captures/bluetooth/blue_hydra_${START_TIME}.out
  cd /opt/pwnix/blue_hydra/
  trap f_endsummary INT
  trap f_endsummary KILL
  trap f_intbh SIGHUP
  ./bin/blue_hydra
  f_endsummary
fi
