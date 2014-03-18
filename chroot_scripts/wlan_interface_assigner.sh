#!/system/bin/sh
# Pwnie Express: PwnPad Script to assign internal wlan hardware to "wlan0" and external wlan hardware to "wlan1".
# Revision 3.18.2013
# Authors: Grep and Awk

# Checking to see if this is the old pad or the new pad:
cat /proc/cpuinfo |grep grouper &> /dev/null
pad_old_or_new=`echo $?`

# If pad_old_or_new = 1 then current device is New Pad
if [ $pad_old_or_new -eq 1 ]; then
  
  # New Pad wlan fix:

    # Acquire MAC address of internal wlan hardware and save as variable
    onboard_wlan_mac=`grep "^Intf0MacAddress=" /data/misc/wifi/WCNSS_qcom_cfg.ini | awk -F"=" '{print$2}' | sed -e 's/\([0-9A-Fa-f]\{2\}\)/\1:/g' -e 's/\(.*\):$/\1/'`
    
    # Acquire MAC address of external wlan USB adapter and save as variable
    external_wlan_mac=`busybox ifconfig -a | grep "^wlan" | grep -v "${onboard_wlan_mac}" | awk '{print$5}'`
    
    # Added sleep 15 in order to ensure svc commands run properly on boot - needed more time
    sleep 15
    
    # Disable Android wifi manager
    svc wifi disable
    sleep 1
    
    # Assign a temporary inferface name to internal wlan
    busybox nameif temp_onboard "${onboard_wlan_mac}"
    
    # Assign a temporary inferface name to external wlan
    busybox nameif temp_external "${external_wlan_mac}"
    
    # Assign internal wlan hardware to "wlan0"
    busybox nameif wlan0 "${onboard_wlan_mac}"
    
    # Assign external wlan hardware to "wlan1"
    busybox nameif wlan1 "${external_wlan_mac}"
    
    # Re-enable Android wifi manager
    svc wifi enable

else
  
  # Old pad wlan fix:

    # Added sleep 15 in order to ensure svc commands run properly on boot - needed more time
    sleep 15
    
    # Enable wifi to grab onboard mac address
    svc wifi enable
    
    sleep 5
    # Acquire MAC address of internal wlan hardware and save as variable
    onboard_wlan_mac=`dmesg |egrep -ri "Broadcom Dongle Host Driver mac=" | awk '{print$10}' |awk -F"mac=" '{print$1$2$3$4$5$6}' | head -n 1`
    
    #echo $onboard_wlan_mac
    
    # Acquire MAC address of external wlan USB adapter and save as variable
    external_wlan_mac=`busybox ifconfig -a | grep "^wlan" | grep -iv "${onboard_wlan_mac}" | awk '{print$5}'`
    
    
    sleep 2
    # Disable Android wifi manager
    svc wifi disable
    sleep 1
    
    # Assign a temporary inferface name to internal wlan
    busybox nameif temp_onboard "${onboard_wlan_mac}"
    
    # Assign a temporary inferface name to external wlan
    busybox nameif temp_external "${external_wlan_mac}"
    
    # Assign internal wlan hardware to "wlan0"
    busybox nameif wlan0 "${onboard_wlan_mac}"
    
    # Assign external wlan hardware to "wlan1"
    busybox nameif wlan1 "${external_wlan_mac}"
    
    # Re-enable Android wifi manager
    svc wifi enable
    

fi
