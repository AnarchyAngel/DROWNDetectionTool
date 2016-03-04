#!/bin/bash
usage() {
    echo >&2 << USAGE
$0 [-p PORT] targets ...

    -p  port number to contact on target
        defaults to 443 (HTTPS)

examples
    $ $0 -p 6697 example.com
    $ cat targets.txt | $0
    $ $0 targets.txt
USAGE
}

port=443 # default

port_open() {
    local target="$1"
    nmap -sT -p"$port" -T5 --open "$target" 2>&1 | grep -q "open"
}

check() {
    local target="$1"
    NC='\e[0m' # No Color
    green='\e[0;32m'
    red='\e[0;31m'

    echo -n "[*] Checking if ${target} is up and listening on ${port}... "
    if port_open "$target"; then
        echo "OK"
        echo -e "${green}[*] ${target} is up and listening on ${port}.${NC}"
        echo -e "${green}[*] Checking for DROWN.${NC}"
        if timeout -k 0m 15s java -jar TestSSLServer.jar "$target" "$port" | grep -q "SSLv2"; then
            echo -e "${red}[*] ${target} is open to DROWN${NC}"
        fi
    else
        echo "not responding"
    fi
}

if [[ "$1" == "-p" ]]; then
    shift
    # make sure following arg is a digit
    if grep -q "[0-9]\+" <<< "$1"; then
        port="$1"
        shift
    fi
fi

# check if targets passed via arguments
# probably a cleaner way to do this
if (( $# > 0 )); then
    if [[ -f "$1" ]]; then
        # argument is a file, read it in
        while read target; do check "$target"; done < "$1"
    else
        # single or list of targets
        while read target; do check "$target"; done <<< "$*"
    fi
else
    # piped targets
    while read target -t 0.1; do check "$target"; done
fi
