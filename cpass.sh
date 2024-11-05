#!/bin/sh
printf -v lowerc "%s" {qwertyuiopasdfghjklzxcvbnm}
upperc='QWERTYUIOPASDFGHJKLZXCVBNM'
numc='1234567890'
specc='!@#$%^&*()'


users=($(grep -vE "nologin|$(id -un)|root" /etc/passwd | grep -oE "^[^:]{1,}"))
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
    for (( i=0; i < ($RANDOM%3)+3; i++ )); do
        pass+=$(get4)
    done
    echo "${pass}"
}

for user in users; do
    echo "$(dopass)" | sudo passwd -s "${user}"
done
printf "Change root password:\n"
sudo passwd root

printf "Change your password:\n"
passwd $(id -un)