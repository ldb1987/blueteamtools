#!/bin/bash

backupLocation="/etc/fonts"
distribution="$(grep -E "^NAME" /etc/os-release | grep -oE "\"[A-Za-z ]{1,}\"" | tr -d "\"")"

#$1: service to backup
#$2: backup directory
backupConfig() {
    case $1 in
        openssh-server)
            sudo cp -r "/etc/ssh" "$2/.ssh";;
        httpd)
            sudo cp -r "/etc/httpd/" "$2/.httpd";;
        dovecot)
            sudo cp -r "/etc/dovecot" "$2/.dovecot";;
        postfix)
            sudo cp -r "/etc/postfix" "$2/.postfix";;
    esac
}
#$1: service to backup
#$2: backup directory
restoreConfig() {
    case $1 in
        openssh-server)
            sudo cp -r "$2/.ssh" "/etc/ssh";;
        httpd)
            sudo cp -r "$2/.httpd" "/etc/httpd";;
        dovecot)
            sudo cp -r "$2/.dovecot" "/etc/dovecot";;
        postfix)
            sudo cp -r "$2/.postfix" "/etc/postfix";;
    esac
}
#$1: service
reinstallService() {
    install=""
    case $distribution in
        "Rocky Linux")
            dnf reinstall -y "${1[@]}";;
        Ubuntu)
            apt install -y --reinstall "$1";;
        Debian)
            apt install -y --reinstall "$1";;
    esac

    sudo "$install $1"
}

showHelp() {
    echo "Options:"
    echo "-h show this help page"
    echo "-b [service list] [path] backup config directory for a comma-separated list of services. Backup path is optional"
    echo "-i [service list] [path] reinstall services and restore configs from a specified backup path"
    echo "-r [service list] [path] restore configs for services in a comma-separated list. Backup path is optional"
}

if [[ -n "$3" ]]; then 
    backupLocation="$3"
fi

while getopts "hb:i:r:" option; do
    case $option in
        h)
            showHelp
            exit;;
        b)
            declare -a serviceList

            IFS="," read -r -a serviceList <<< "$OPTARG"

            for svc in "${serviceList[@]}"; do
                backupConfig "$svc" "$backupLocation"
            done;;
        i)
            declare -a serviceList

            IFS="," read -r -a serviceList <<< "$OPTARG"
            case $distribution in
                "Rocky Linux")
                    dnf reinstall -y "${serviceList[@]}";;
                Ubuntu)
                    apt install -y --reinstall "${serviceList[@]}";;
                Debian)
                    apt install -y --reinstall "${serviceList[@]}";;
            esac
            for svc in "${serviceList[@]}"; do
                restoreConfig "$svc" "$backupLocation"
            done;;
        r)
            declare -a serviceList

            IFS="," read -r -a serviceList <<< "$OPTARG"

            for svc in "${serviceList[@]}"; do
                restoreConfig "$svc" "$backupLocation"
            done;;
    esac
done