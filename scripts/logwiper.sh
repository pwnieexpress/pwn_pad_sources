#!/bin/bash

/etc/init.d/ssh start
ssh -t root@localhost "cd /opt/pwnpad/scripts/ ; ./logwiper1.sh ; bash"
