#!/bin/bash
# Bluetooth scanning / logging script using bluelog
#set the prompt to the name of the script
PS1=${PS1//@\\h/@blue_hydra}
clear

bluetooth=1
. /opt/pwnix/pwnpad-scripts/px_functions.sh

f_endsummary() {
  clear
  printf "\n[-] Blue_Hydra db file saved to /opt/pwnix/blue_hydra.db\n\n"
  printf "\n[-] Blue_Hydra summary saved to /opt/pwnix/captures/blue_hydra_${START_TIME}.out\n\n"
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

echo $QUERY | sqlite3 -header -column /opt/pwnix/blue_hydra.db > $FILENAME
}

if loud_one=1 f_validate_one hci0; then
  hciconfig hci0 up
  cd /opt/pwnix/blue_hydra/
  service dbus status || service dbus start
  service bluetooth status || service bluetooth start
  clear
  START_TIME=$(date +"%s")
  FILENAME=/opt/pwnix/captures/blue_hydra_${START_TIME}.out
  cd /opt/pwnix/captures/bluetooth
  trap f_endsummary INT
  trap f_endsummary KILL
  ./bin/blue_hydra
  f_endsummary
fi
