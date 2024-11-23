#/bin/sh

logDir="$HOME/logs"

declare -a authUsers
authUsers+=("president")
authUsers+=("vicepresident")
authUsers+=("defenseminister")
authUsers+=("secretary")
authUsers+=("general")
authUsers+=("admiral")
authUsers+=("judge")
authUsers+=("bodyguard")
authUsers+=("cabinetofficial")
authUsers+=("treasurer")

mkdir -p "$logDir"
grep -vE "nologin" /etc/passwd > "$logDir/users"

#printf "%s\n\n%s\n\n%s\n\n%s\n\n%s\n\n%s\n" "---Available Users---" "$(< $logDir/users)" "---Logged-In Users---" "$(< $logDir/logged-in)" "---Failed Services---" "$(< $logDir/failed-services)"

getactiveservices() {
    systemctl list-units --state=active | sed "s/^  //g" | grep -oE '^[^ ]{1,}' | tee $logDir/active-services
}

getfailedservices() {
    systemctl list-units --state=failed | tee $logDir/failed-services
}

showreverseshells() {
    ps aux | grep -E 'ncat'
}

showlisteners() {
    sudo ss -lnp | sed "s/  / /g"
}

getActiveUsers() {
    who > "$logDir/logged-in"
}

showActiveUsers() {
    printf "%s\n\n%s\n" "---Logged-In Users---" "$(< $logDir/logged-in)"
}

checkssh() {
    printf "Checking sshd config...\n"

    sudo grep "PermitRootLogin" /etc/ssh/sshd_config
    sudo grep "Port:" /etc/ssh/sshd_config
    sudo grep "UsePAM" /etc/ssh/sshd_config
}

showNetInfo() {
    ip a | grep -vE "127.0.0.1" | grep -oE "inet [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}"
    ip r | grep -oE "default via [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}"
}

auditservices() {
    active_service_entries_log="$logDir/$(date | sed "s/_//g")active-service-entries"
    echo "$active_service_entries_log"
    touch "$active_service_entries_log"
    while read -r LINE; do
        sudo systemctl cat $LINE >> "$active_service_entries_log"
        sudo systemctl cat $LINE
    done < "$logDir/active-services"
}

showHelp() {
    printf "h: help
services: audit services
active-users: show logged in users
quit: quit
ssh: show ssh configurations\n
"
}

getNoAuth() {
    grep -ovE "president|vicepresident|defenseminister|secretary|admiral|judge|general|bodyguard|cabinetofficial|treasurer" "$logDir/users"
}

getUsers() {
    cat "$logDir/users"
}

mainLoop() {
    cmd=""
    while read -p "Enter command to run or '?' for help\$ " cmd; do
    echo "$cmd"
        if [ -z "$cmd" ]; then
            continue
        elif [ "$cmd" == "quit" ]; then
            break
        elif [ "$cmd" == "services" ]; then
            getactiveservices
            auditservices
        elif [ "$cmd" == "?" ]; then
            showHelp
        elif [ "$cmd" == "active-users" ]; then
            getActiveUsers
            showActiveUsers
        elif [ "$cmd" == "ssh" ]; then
            checkssh
        elif [ "$cmd" == "listeners" ]; then
            showlisteners
        elif [ "$cmd" == "rshell" ]; then
            showreverseshells
        elif [ "$cmd" == "ip" ]; then
            showNetInfo
        else
            printf "Usage:\n%s" "$(showHelp)"
        fi
    done
}

while getopts "hqsualrn" option; do
        case $option in
            h)
                showHelp
                exit;;
            q)
                break;;
            s)
                getactiveservices
                auditservices
                exit;;
            u)
                getActiveUsers
                showActiveUsers
                exit;;
            a)
                getNoAuth
                exit;;
            l)
                showlisteners
                exit;;
            r)
                showreverseshells
                exit;;
            n)
                showNetInfo
                exit;;
            p)
                getUsers
                exit;;
        esac
    done