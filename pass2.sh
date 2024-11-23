#!/bin/sh

if [ ! "$(id -u)" == "0" ]; then
    echo "This script must be run as root"
    exit
fi

for user in president vicepresident defenseminister secretary general admiral judge bodyguard cabinetofficial treasurer; do
    pass=$(tr -dc 'A-Za-z0-9!@#$=' < /dev/urandom | head -c 14)
    echo "$user:$pass" | chpasswd
    if [[ "$1" == "-s" ]]; then
        echo "$user : $pass"
    fi
done