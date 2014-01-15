#/bin/bash

clear
echo "    Warning, this update will overwrite any modifed config files !"
echo
echo "    Do you want to continue?"
echo
echo "1. Yes"
echo "2. No"
echo
read -p "Choice: " choice


if [ $choice -eq 1 ]
then

/opt/pwnix/chef/update.sh

echo
echo
echo "    Congratulations your Pad has been updated!"

else
  exit
fi

