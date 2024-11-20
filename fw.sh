#!/bin/bash

start() {
    #clear existing rules
    sudo iptables -F
    sudo iptables -t nat -F
    sudo iptables -t mangle -F

    #inbound
    sudo iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT #accept inbound traffic from established connections
    sudo iptables -A INPUT -p tcp --sport 5002 -m state --state NEW #datadog rule that heopfully works (it probably won't tho)
    sudo iptables -A OUTPUT -j LOG --log-prefix "FW_IN: " --log-level info #logging for bloked connections in
    sudo iptables -A INPUT DROP #deny by default

    #outbound
    sudo iptables -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT #allow outbound traffic from established connections
    sudo iptables -A OUTPUT -p tcp --dport 443 -m state --state NEW -j ACCEPT #allow 443 (for https) traffic out; needed for package managers
    sudo iptables -A OUTPUT --dport 53 -m state --state NEW -j ACCEPT #allow 53 out; needed for DNS
    sudo iptables -A OTUPUT -p tcp --dport 5002 -m state --state NEW -j ACCEPT #allow 5002 out; default port for data dog which hopefully prevents firewall from blocking datadog (if the default port is used)
    sudo iptables -A OUTPUT -j LOG --log-prefix "FW_OUT: " --log-level info #Logging for blocked connections out
    sudo iptables -A OUTPUT -j DROP #deny by default
}

universal() {
    
}

propaganda() {
    #inbound
    sudo iptables -I INPUT 3 -p tcp --dport 80 -m state --state NEW -j ACCEPT #alloy tcp port 80 in for http
    sudo iptables -A INPUT 4 -p tcp --dport 443 -m state --state NEW -j ACCEPT #https
    sudo iptables -A INPUT 5 -p tcp --dport 22 -m state --state NEW -j ACCEPT #ssh
    

    #outbound
    
}

wiretap() {
    sudo iptables -A INPUT 5 -p tcp --dport 143 -m state --state NEW -j ACCEPT #imap insecure
    sudo iptables -A INPUT 5 -p tcp --dport 993 -m state --state NEW -j ACCEPT #imap secure
    sudo iptables -A INPUT 5 -p tcp --dport 25 -m state --state NEW -j ACCEPT #smtp insecure
    sudo iptables -A INPUT 5 -p tcp --dport 2525 -m state --state NEW -j ACCEPT #smtp insecure
    sudo iptables -A INPUT 5 -p tcp --dport 465 -m state --state NEW -j ACCEPT #smtp insecure
    sudo iptables -A INPUT 5 -p tcp --dport 587 -m state --state NEW -j ACCEPT #smtp secure
}

vault() {
    sudo iptables -A INPUT 5 -p tcp --dport 20 -m state --state NEW -j ACCEPT
    sudo iptables -A INPUT 5 -p tcp --dport 21 -m state --state NEW -j ACCEPT
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
