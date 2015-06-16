#!/system/bin/sh
# Set internal wlan to wlan0 and external wlan to wlan1
# Author: Zero_Chaos
#una salus victis nullam sperare salutem

WLAN_SWITCHAROO=0
REENABLE_WIFI=0

#Check if wlan0 is usb
if [ -f /sys/class/net/wlan0/device/modalias ];then
  WLAN0_BUS=$(awk -F: '{print $1}' /sys/class/net/wlan0/device/modalias)
  if [ "$WLAN0_BUS" = "usb" ]; then
    printf "Interface wlan0 is usb.\n"
    if [ -f /sys/class/net/wlan1/device/modalias ];then
      #check if wlan1 is usb
      WLAN1_BUS=$(awk -F: '{print $1}' /sys/class/net/wlan1/device/modalias)
      if [ "$WLAN1_BUS" = "sdio" ]; then
        printf "Interface wlan1 is sdio.\n"
        WLAN_SWITCHAROO=1
      elif [ "$WLAN1_BUS" = "usb" ]; then
        printf "Interface wlan1 is also usb, dazed and confused, failure.\n"
        return 1
      else
        printf "Interface wlan1 exists but isn't usb or sdio, failure.\n"
        return 1
      fi
    else
      printf "Interface wlan1 does not seem to exist, nothing to do.\n"
      return 0
    fi
  elif [ "$WLAN0_BUS" = "sdio" ]; then
    printf "Interface wlan0 is already the internal sdio wifi nic.\n"
    return 0
  else
    printf "Interface wlan0 exists but isn't usb or sdio, failure.\n"
    return 1
  fi
else
  printf "Unable to use modalias to determine which device wlan0 is.\n"
  return 1
  #/system/bin/wlan_interface_assigner.sh
fi

if [ "$WLAN_SWITCHAROO" = "1" ]; then
  printf "Switching wlan0 and wlan1..."
  onboard_wlan_mac=$(/system/xbin/busybox ifconfig -a | grep "^wlan1" | awk '{print $5}')
  external_wlan_mac=$(/system/xbin/busybox ifconfig -a | grep "^wlan0" | awk '{print $5}')

  if [ "$(/system/bin/getprop wlan.driver.status)" != "unloaded" ]; then
    # Disable Android wifi manager
    /system/bin/svc wifi disable
    sleep 2
    REENABLE_WIFI=1
  fi

  #down interfaces
  /system/xbin/busybox ifconfig wlan0 down
  /system/xbin/busybox ifconfig wlan1 down

  # Set temporary interface name for internal wlan
  /system/xbin/busybox nameif temp_onboard "${onboard_wlan_mac}"

  # Set temporary interface name for external wlan
  /system/xbin/busybox nameif temp_external "${external_wlan_mac}"

  # Set internal wlan to wlan0
  /system/xbin/busybox nameif wlan0 "${onboard_wlan_mac}"

  # Set external wlan to wlan1
  /system/xbin/busybox nameif wlan1 "${external_wlan_mac}"

  if [ "$REENABLE_WIFI" = "1" ]; then
    # Re-enable Android wifi manager
    /system/bin/svc wifi enable
  fi
  printf "Complete.\n"
fi
