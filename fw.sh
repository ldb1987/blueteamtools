#!/bin/bash

start() {
    #clear existing rules
     iptables -F
     iptables -t nat -F
     iptables -t mangle -F

     iptables -P INPUT DROP
     iptables -P OUTPUT DROP
     iptables -P FORWARD DROP

    #inbound
     iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT #accept inbound traffic from established connections
     iptables -A INPUT -i lo -j ACCEPT
     iptables -A INPUT -j LOG --log-prefix "FW_IN: " --log-level info #logging for blocked connections in

    #outbound
     iptables -A OUTPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT #allow outbound traffic from established connections
     iptables -A OUTPUT -o lo -j ACCEPT
     iptables -A OUTPUT -j LOG --log-prefix "FW_OUT: " --log-level info #Logging for blocked connections out

    global
    dd
}

global() {
     iptables -N GLOBALIN
     iptables -N GLOBALOUT

     iptables -A GLOBALIN -s 172.16.1.0/24 -j ACCEPT
     iptables -A GLOBALIN -s irsec.club -j ACCEPT
     iptables -A GLOBALIN -s stack.ritsec.cloud -j ACCEPT
     iptables -A GLOBALIN -s compsole.ritsec.cloud -j ACCEPT

     iptables -A GLOBALOUT -d 172.16.1.0/24 -j ACCEPT
     iptables -A GLOBALOUT -p tcp --dport 443 -m conntrack --ctstate NEW -j ACCEPT #allow 443 (for https) traffic out; needed for package managers
     iptables -A GLOBALOUT -p tcp --dport 80 -m conntrack --ctstate NEW -j ACCEPT #allow 53 out; needed for DNS
     iptables -A GLOBALOUT -p udp --dport 53 -m conntrack --ctstate NEW -j ACCEPT #allow 53 out; needed for DNS
     iptables -A GLOBALOUT -p tcp --dport 53 -m conntrack --ctstate NEW -j ACCEPT #allow 53 out; needed for DNS
     iptables -A GLOBALOUT -d irsec.club -j ACCEPT
     iptables -A GLOBALOUT -d stack.ritsec.cloud -j ACCEPT
     iptables -A GLOBALOUT -d compsole.ritsec.cloud -j ACCEPT

     iptables -A GLOBALIN -j RETURN
     iptables -A GLOBALOUT -j RETURN

     iptables -I INPUT 3 -j GLOBALIN
     iptables -I OUTPUT 3 -j GLOBALOUT
}

#Data Dog Chain
dd() {
     iptables -N DDOGIN
     iptables -N DDOGOUT
    
    
    declare -a ddog

    ddogstr=$(grep -oE "[0-9]{1,}\.[0-9]{1,}\.[0-9]{1,}\.[0-9]{1,}/[0-9]{1,2}" <<< "$(curl https://ip-ranges.us5.datadoghq.com)")

    while read -r line; do
        iptables -A DDOGIN -s "$line" -j LOG --log-prefix "DDOG_IN: " --log-level info
         iptables -A DDOGIN -s "$line" -j ACCEPT
         iptables -A DDOGOUT -d "$line" -j LOG --log-prefix "DDOG_OUT: " --log-level info
         iptables -A DDOGOUT -d "$line" -j ACCEPT
    done <<< $ddogstr

     iptables -A DDOGIN -j RETURN
     iptables -A DDOGOUT -j RETURN

     iptables -I INPUT 4 -j DDOGIN
     iptables -I OUTPUT 4 -j DDOGOUT
}

propaganda() {

     iptables -N PROPIN
     iptables -N PROPOUT
    
    #inbound
     iptables -A PROPIN -p tcp --dport 80 -m conntrack --ctstate NEW -j ACCEPT #alloy tcp port 80 in for http
     iptables -A PROPIN -p tcp --dport 443 -m conntrack --ctstate NEW -j ACCEPT #https
     iptables -A PROPIN -p tcp --dport 22 -m conntrack --ctstate NEW -j ACCEPT #ssh
    iptables -A PROPIN -j RETURN

    #outbound
    iptables -A PROPOUT -p tcp --dport 80 -j ACCEPT
    iptables -A PROPOUT -p tcp --dport 443 -j ACCEPT

    

    
     iptables -I INPUT 5 -j PROPIN
     iptables -I OUTPUT 5 -j PROPOUT
}

wiretap() {
     iptables -N WIREIN
     iptables -N WIREOUT
     

    for port in 143 993 25 2525 465 587; do
         iptables -A WIREIN -p tcp --dport "$port" -m conntrack --ctstate NEW -j ACCEPT
    done

    for port in 25 2525 465 587; do
         iptables -A WIREOUT -p tcp --dport "$port" -m conntrack --ctstate NEW -j ACCEPT
    done

     iptables -A WIREIN -j RETURN
     iptables -A WIREOUT -j RETURN

     iptables -I INPUT 5 -j WIREIN
     iptables -I OUTPUT 5 -j WIREOUT
}

vault() {
    iptables -N VAULTIN
    iptables -N VAULTOUT
     
     iptables -A VAULTIN -p tcp --dport 21 -m conntrack --ctstate NEW -j ACCEPT

    iptables -A VAULTOUT -p tcp --sport 20 -m conntrack --ctstate NEW -j ACCEPT

     iptables -A VAULTIN -j RETURN
     iptables -A VAULTOUT -j RETURN


     iptables -I INPUT 5 -j VAULTIN
     iptables -I OUTPUT 5 -j VAULTOUT
}

addon() {
    if [[ -z "$1" ]]; then
        exit
    fi
    declare -a ports
    IFS="," read -r -a ports <<< "$1"

    for port in "${ports[@]}"; do
         iptables -A INPUT 6 -p tcp "--'$2'port" "$port" -m conntrack --ctstate NEW -j ACCEPT
    done
}

#$1 input chain name
#$2 comma-separated ports or ip addresses
#$3 optional- output chain name
customInput() {
     iptables -N "$1"
    declare -a src

    IFS="," read -r -a src <<< "$2"
}

reset() {
    iptables -F

    iptables -t nat -F
    iptables -t mangle -F

    for chain in GLOBALIN GLOBALOUT DDOGIN DDOGOUT PROPIN WIREIN WIREOUT VAULTIN VAULTOUT; do
        iptables -X "$chain" 2>/dev/null
    done
    
    iptables -P INPUT ACCEPT
    iptables -P OUTPUT ACCEPT
    iptables -P FORWARD ACCEPT
}

if [ ! "$(id -u)" == "0" ]; then
    echo "This script must be run as root"
    exit
fi

distribution="$(grep -E "^NAME" /etc/os-release | grep -oE "\"[A-Za-z ]{1,}\"" | tr -d "\"")"

if [[ "$1" == "-s" ]]; then
    case $distribution in
        "Rocky Linux")
            /sbin/iptables-save > /etc/sysconfig/iptables
            exit;;
        Ubuntu)
            /sbin/iptables-save > /etc/iptables/rules.v4
            exit;;
        Debian)
            /sbin/iptables-save > /etc/iptables/rules.v4
            exit;;
    esac
fi

reset

if [[ ! "$1" == "-r" ]]; then
start
fi

if [[ -z "$1" ]]; then
exit
fi

while getopts "hrpwva:" option; do
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
        r)
            exit;;
        
    esac
done