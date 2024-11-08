#!/bin/sh
lowerc='qwertyuiopasdfghjklzxcvbnm'
upperc='QWERTYUIOPASDFGHJKLZXCVBNM'
numc='1234567890'
special='!@#$%^&*(),.<>?]=+-_[};:{'


#users=($(grep -vE "nologin|$($USER)|root" /etc/passwd | grep -oE "^[^:]{1,}"))
users=['president']
echo "This script will randomly change the password of all users on this system with login shells.
        Upon completion, you will be prompted to change your own password.
        Continue? [Y/N]"

getPChars() {
    for (( i=0; i<($RANDOM%10)+4; i++ )); do
        echo "$1" | sed "s/./&\n/g" | grep . | shuf | head -1
    done
}

dopass2() {
    chars=''
    for s in lowerc upperc numc special; do
        echo $(getPChars "${!s}") | shuf
    done | tr -d " \n"
    #shuf -e $chars | tr -d " \n"

}

#for user in users; do
    #echo "$(dopass)" | sudo passwd -s "${user}"
#done
#printf "Change root password:\n"
#sudo passwd root

#printf "Change your password:\n"
#passwd $($USER)
for s in lowerc upperc numc special; do
    echo $(getPChars "${!s}") | shuf
done | tr -d " "