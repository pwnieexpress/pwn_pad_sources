#!/bin/bash
#Script to run msfconsole with no flags
#set the prompt to the name of the script
PS1=${PS1//@\\h/@msfconsole}
clear

printf "\n[!] Starting Metasploit.. This is gonna take a sec..\n"

msfconsole

