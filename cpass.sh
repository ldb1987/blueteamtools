#!/bin/sh
printf -v lowerc "%s" {qwertyuiopasdfghjklzxcvbnm}
upperc='QWERTYUIOPASDFGHJKLZXCVBNM'
numc='1234567890'
specc='!@#$%^&*()'


users=($(grep -vE "nologin|$(whoami)" /etc/passwd | grep -oE "^[^:]{1,}"))
echo "This script will randomly change the password of all users on this system with login shells.
        Upon completion, you will be prompted to change your own password.
        Continue? [Y/N]"
get4() {
    for s in lowerc upperc numc specc; do
        echo "${!s}" | sed "s/./&\n/g" | grep . | shuf | head -1
    done | tr -d "\n"
}

dopass() {
    pass=''
    #echo "$(get4)$(get4)$(get4)$(get4)" | sed "s/./&\n/g" | grep . | shuf | tr -d "\n"
    for (( i=0; i < ($RANDOM%3)+3; i++ )); do
        pass+=$(get4)
    done
    echo "${pass}"
}

for user in users; do
    echo "$(dopass)" | passwd -s "${user}"
done
passwd $(id -un)
dopass