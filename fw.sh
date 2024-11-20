#!/bin/bash

start() {
    #clear existing rules
    sudo iptables -F
    sudo iptables -t nat -F
    sudo iptables -t mangle -F

    #inbound
    sudo iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT #accept inbound traffic from established connections
    sudo iptables -A INPUT -j LOG --log-prefix "FW_IN: " --log-level info #logging for bloked connections in
    sudo iptables -A INPUT -j DROP #deny by default

    #outbound
    sudo iptables -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT #allow outbound traffic from established connections
    sudo iptables -A OUTPUT -j LOG --log-prefix "FW_OUT: " --log-level info #Logging for blocked connections out
    sudo iptables -A OUTPUT -j DROP #deny by default

    global
    dd
}

global() {
    sudo iptables -N GLOBALIN
    sudo iptables -N GLOBALOUT

    sudo iptables -I INPUT 2 -j GLOBALIN
    sudo iptables -I OUTPUT 2 -j GLOBALOUT

    sudo iptables -A GLOBALIN -s 172.16.1.0/24 -j ACCEPT

    sudo iptables -A GLOBALOUT -d 172.16.1.0/24 -j ACCEPT
    sudo iptables -A GLOBALOUT -p tcp --dport 443 -m state --state NEW -j ACCEPT #allow 443 (for https) traffic out; needed for package managers
    sudo iptables -A GLOBALOUT --dport 53 -m state --state NEW -j ACCEPT #allow 53 out; needed for DNS

    sudo iptables -A GLOBALIN -j RETURN
    sudo iptables -A GLOBALOUT -j RETURN
}

#Data Dog Chain
dd() {
    sudo iptables -N DDOGIN
    sudo iptables -N DDOGOUT
    sudo iptables -I INPUT 3 -j DDOGIN
    sudo iptables -I OUTPUT 3 -j DDOGOUT
    
    declare -a ddog

    ddogstr=$(grep -oE "[0-9]{1,}\.[0-9]{1,}\.[0-9]{1,}\.[0-9]{1,}/[0-9]{1,2}" <<< "$(curl https://ip-ranges.us5.datadoghq.com)")

    while read -r line; do
        sudo iptables -A DDOGIN -s "$line" -j ACCEPT
        sudo iptables -A DDOGOUT -s "$line" -j ACCEPT
    done <<< $ddogstr

    sudo iptables -A DDOGIN -j RETURN
    sudo iptables -A DDOGOUT -j RETURN
}

propaganda() {

    sudo iptables -N PROPIN
    sudo iptables -I INPUT 4 -j PROPIN
    #inbound
    sudo iptables -A PROPIN -p tcp --dport 80 -m state --state NEW -j ACCEPT #alloy tcp port 80 in for http
    sudo iptables -A PROPIN -p tcp --dport 443 -m state --state NEW -j ACCEPT #https
    sudo iptables -A PROPIN -p tcp --dport 22 -m state --state NEW -j ACCEPT #ssh
    

    #outbound
    sudo iptables -A PROPIN -j RETURN
}

wiretap() {
    sudo iptables -N WIREIN
    sudo iptables -N WIREOUT
    sudo iptables -I INPUT 4 -j WIREIN
    sudo iptables -I OUTPUT 4 -j WIREOUT

    for port in 143 993 25 2525 465 587; do
        sudo iptables -A WIREIN 5 -p tcp --dport "$port" -m state --state NEW -j ACCEPT
    done

    for port in 25 2525 465 587; do
        sudo iptables -A WIREOUT 5 -p tcp --dport "$port" -m state --state NEW -j ACCEPT
    done

    sudo iptables -A WIREIN -j RETURN
    sudo iptables -A WIREOUT -j RETURN
}

vault() {
    iptables -N VAULTIN
    sudo iptables -I INPUT 4 -j VAULTIN

    sudo iptables -A VAULTIN -p tcp --dport 20 -m state --state NEW -j ACCEPT
    sudo iptables -A VAULTIN -p tcp --dport 21 -m state --state NEW -j ACCEPT

    sudo iptables -A VAULTIN -j RETURN
}

addon() {
    declare -a ports
    IFS="," read -r -a ports <<< "$1"

    for port in "${ports[@]}"; do
        sudo iptables -A INPUT 5 -p tcp "--'$2'port" "$port" -m state --state NEW -j ACCEPT
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
            ports=$OPTARG;;
        d)
            addon "$ports" d
            exit;;
        s)
            addon "$ports" s
            exit;;
        
    esac
done
