#!/system/bin/sh
# Set internal wlan to wlan0 and external wlan to wlan1
# Author: Grep, Awk, t1mz0r, Zero_Chaos

# Delay script start for Android bootup
# Sleep long enough for svc commands to run at boot
sleep 20
# Enable Android wifi manager to snag onboard MAC address
svc wifi enable
sleep 5

# Check device
hardw=`getprop ro.hardware`
if [ "$hardw" = "deb" ] || [ "$hardw" = "flo" ]; then
  # Fix for new Pwn Pad
  # Get MAC address of internal wlan and save as variable
  onboard_wlan_mac=`grep "^Intf0MacAddress=" /data/misc/wifi/WCNSS_qcom_cfg.ini | awk -F"=" '{print$2}' | sed -e 's/\([0-9A-Fa-f]\{2\}\)/\1:/g' -e 's/\(.*\):$/\1/'`
else
  ## Get MAC address of internal wlan and save as variable
  #Nexus 2012 and Nexus 5
  onboard_wlan_mac=`dmesg |egrep -i "Broadcom Dongle Host Driver mac=" | awk '{print$10}' |awk -F"mac=" '{print$1$2$3$4$5$6}' | head -n 1`
  #Nvidia Shield (lte version is tn8 but need confirmation on non-lte
  [ -z "$onboard_wlan_mac" ] && onboard_wlan_mac=`dmesg |egrep -i "Broadcom Dongle Host Driver" | awk '{print$11}' |awk -F"MAC=" '{print$1$2$3$4$5$6}' | head -n 1`
fi

# Get MAC address of external wlan USB adapter and save as variable
external_wlan_mac=`busybox ifconfig -a | grep "^wlan" | grep -iv "${onboard_wlan_mac}" | awk '{print$5}'`

# Disable Android wifi manager
svc wifi disable
sleep 2

# Set temporary interface name for internal wlan
busybox nameif temp_onboard "${onboard_wlan_mac}"

# Set temporary interface name for external wlan
busybox nameif temp_external "${external_wlan_mac}"

# Set internal wlan to wlan0
busybox nameif wlan0 "${onboard_wlan_mac}"

ifconfig wlan0 up
# Set external wlan to wlan1
busybox nameif wlan1 "${external_wlan_mac}"

# Re-enable Android wifi manager
svc wifi enable
