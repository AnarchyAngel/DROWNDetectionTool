#!/bin/bash
port=443 # default

if [[ "$1" == "-p" ]]; then
    shift
    # make sure following arg is a digit
    if grep -q "[0-9]+" <<< "$1"; then
        port="$1"
        shift
    fi
fi

TARGETS=$*

while IFS='' read -r line || [[ -n "$line" ]]; do
    echo "[*] Checking if $line is up and listening on 443..."
    NMAP="$(nmap -sT -p443 -T5 --open $line|grep open)"
    if [[ -n $NMAP ]];
    then
     green='\e[0;32m'
     NC='\e[0m' # No Color
     echo -e "${green}[*] $line is up and listening on 443.${NC}"
     echo -e "${green}[*] Checking for DROWN.${NC}"
     TEST="$(timeout -k 0m 10s java -jar TestSSLServer.jar $line 443|grep SSLv2)"
     if [[ -n $TEST ]];
     then
      red='\e[0;31m'
      NC='\e[0m' # No Color
      echo -e "${red}[*] $line is open to DROWN${NC}"
     fi
    fi
done < "$TARGETS"
