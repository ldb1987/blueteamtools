#!/bin/sh

declare -a users = {"president",
                    "vicepresident",
                    "defenseminister",
                    "secretary",
                    "general",
                    "admiral",
                    "judge",
                    "bodyguard",
                    "cabinetofficial",
                    "treasurer"}

#IFS=" " read -r -a users <<< "$1"

for user in users; do
    echo "$user "
    tr -dc 'A-Za-z0-9!@#$=' < /dev/urandom | head -c 14 | tee | sudo passwd -s $user
done