#!/bin/bash

/etc/init.d/ssh start
ssh -t root@localhost "cd /opt/metasploit-framework/ ; echo " " ; echo " " ; echo "Starting Metasploit this will take a minute" ; ./msfconsole ; bash"

