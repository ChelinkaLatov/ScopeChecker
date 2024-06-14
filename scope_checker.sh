#!/bin/bash

### Variables

ip_pattern='([0-9]{1,3}\.){3}[0-9]{1,3}'
http_pattern='https?://[^ ]+'

### Functions

function usage() {
    echo "$0 <hostnames or ips>"
    echo ""
    echo "Example:"
    echo "        $0 www.google.com"
    echo "        $0 8.8.8.8"
    echo "        $0 8.8.8.8 blog.whiteflag.io"
}

function parse_ip() {
    if [ -z "$1" ]; then
        echo "Please give me a parameter preferrably an ip."
        exit 0
    fi
    echo "---WHOIS LOOKUP FOR $1---"
    whois "$1" | grep -E "inetnum|netname|country|mnt-by|created|last-modified|route" # Prolival && OVH
    whois "$1" | grep -E "CIDR|NetName|Organization" # Cloudflare
    
    echo "---END WHOIS $1---"
}

## Main

if [[ "$1" = "-h" || "$1" = "--help" ]]; then
    usage
    exit 0
fi

if [[ -z "$@" ]]; then
    read -p "Please enter the hostname(s) OR the ip(s) > " host
else
    hosts="$@"
fi

for host in $hosts; do
    if [[ ! "$host" =~ $ip_pattern ]]; then
        echo "Host detected: $host"

            # Request ip addresses from hostnames
            IPS=()
            for word in $(nslookup "$host" | grep -E "^Address: " | awk '{print $2}'); do # --> Gets all ip addresses
                IPS+=("$word")
            done
    else
        IPS=("$host")
    fi

    for ip in ${IPS[*]}; do
        if [[ "$ip" =~ $ip_pattern ]]; then
            echo "Ip address detected: $ip"
            parse_ip "$ip"
        else
            echo "[!] Got unusual ip $ip"
        fi
    done
done
