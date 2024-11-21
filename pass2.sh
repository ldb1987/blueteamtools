#!/bin/sh



#IFS=" " read -r -a users <<< "$1"

for user in president vicepresident defenseminister secretary general admiral judge bodyguard cabinetofficial treasurer; do
    pass=$(tr -dc 'A-Za-z0-9!@#$=' < /dev/urandom | head -c 14)
    echo "$pass" | sudo passwd --stdin $user 1>/dev/null
    echo "$user : $pass"
done