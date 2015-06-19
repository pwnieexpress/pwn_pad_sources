#!/bin/bash
#Script to run Social Engineer Toolkit with no flags.
#set the prompt to the name of the script
PS1=${PS1//@\\h/@setoolkit}
clear

cd /opt/pwnix/captures/
clear
setoolkit
