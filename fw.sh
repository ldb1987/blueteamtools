#!/bin/bash

start() {
    sudo iptables -F
    sudo iptables -t nat -F
    sudo iptables -t mangle -F
}

propaganda() {
    sudo iptables -A INPUT -p tcp -s 0/0 --dport 80 -j ACCEPT #http
    sudo iptables -A INPUT -p tcp -s 0/0 --dport 443 -j ACCEPT #https
    sudo iptables -A INPUT -p tcp -s 0/0 --dport 22 -j ACCEPT #ssh
    sudo iptables -A INPUT -s 0/0 -j LOG --log-prefix "FW: " --log-level info
    sudo iptables -A INPUT -s 0/0 -j DROP
}

wiretap() {
    sudo iptables -A INPUT -p tcp -s 0/0 --dport 143 -j ACCEPT #imap
    sudo iptables -A INPUT -p tcp -s 0/0 --dport 993 -j ACCEPT #imap secure

    sudo iptables -A INPUT -p tcp -s 0/0 --dport 25 -j ACCEPT #smtp
    sudo iptables -A INPUT -p tcp -s 0/0 --dport 2525 -j ACCEPT
    sudo iptables -A INPUT -p tcp -s 0/0 --dport 465 -j ACCEPT
    sudo iptables -A INPUT -p tcp -s 0/0 --dport 587 -j ACCEPT #smtp secure
    
    
    sudo iptables -A INPUT -s 0/0 -j LOG --log-prefix "FW: " --log-level info
    sudo iptables -A INPUT -s 0/0 -j DROP
}

vault() {
    sudo iptables -A INPUT -p tcp -s 0/0 --dport 20 -j ACCEPT #ftp control
    sudo iptables -A INPUT -p tcp -s 0/0 --dport 21 -j ACCEPT #ftp file
    sudo iptables -A INPUT -s 0/0 -j LOG --log-prefix "FW: " --log-level info
    sudo iptables -A INPUT -s 0/0 -j DROP
}

addon() {
    declare -a ports
    IFS="," read -r -a ports <<< "$1"
    for port in "${ports[@]}"; do
        sudo iptables -I INPUT 0 -s 0/0 --dport "$port" -j ACCEPT
    done
}

start

while getopts "hpwva:" option; do
    case $option in
        h)
            help
            exit;;
        p)
            propaganda
            exit;;
        w)
            wiretap
            exit;;
        v)
            vault
            exit;;
        a)
            addon $OPTARG;;
    esac
done
