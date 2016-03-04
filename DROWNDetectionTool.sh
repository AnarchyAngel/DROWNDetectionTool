#!/bin/bash
usage() {
    cat >&2 << USAGE
$0 [-p PORT] targets ...

    -p  port number to contact on target
        defaults to 443 (HTTPS)

examples
    # test port 6697 on example.con
    $0 -p 6697 example.com

    # test port 443 on each target in targets.txt (one per line)
    cat targets.txt | $0

    # same as above without a pipeline
    $0 targets.txt
USAGE
    exit 255
}

port=443 # default

port_open() {
    local target="$1"
    nmap -sT -p"$port" -T5 --open "$target" 2>&1 | grep -q "open"
}

ok() {
    echo -e "\r[\e[0;32mOK\e[0m]"
}
fail() {
    echo -e "\r[\e[0;31m!!\e[0m]"
}
check() {
    local target="$1"

    echo -n "[..] Checking if ${target} is up and listening on ${port}"
    if port_open "$target"; then
        ok
        echo -en "[..] Checking for DROWN"
        if timeout -k 0m 15s java -jar TestSSLServer.jar "$target" "$port" | grep -q "SSLv2"; then
            fail
        else
            ok
        fi
    else
        fail
    fi
}

if [[ "$1" == "-p" ]]; then
    shift
    # make sure following arg is digits
    if grep -q "[0-9]\+" <<< "$1"; then
        port="$1"
        shift
    else
        usage
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
        for target in $*; do check "$target"; done
    fi
else
    show_usage=1
    # piped targets
    while read -t 0.1 target; do
        show_usage=0
        [[ -z "$target" ]] && usage
        check "$target"
    done

    [[ "$show_usage" -eq 1 ]] && usage
fi
