#/bin/sh

logDir="$HOME/logs"

mkdir -p "$logDir"
grep -vE "nologin" /etc/passwd > "$logDir/users"

who > "$logDir/logged-in"
printf "%s\n\n%s\n\n%s\n\n%s\n\n%s\n\n%s\n" "---Available Users---" "$(< $logDir/users)" "---Logged-In Users---" "$(< $logDir/logged-in)" "---Failed Services---" "$(< $logDir/failed-services)"

getactiveservices() {
    systemctl list-units --state=active | sed "s/^  //g" | grep -oE '^[^ ]{1,}' | tee $logDir/active-services
}

getfailedservices() {
    systemctl list-units --state=failed | tee $logDir/failed-services
}

getreverseshells() {
    ps aux | grep -E 'ncat'
}

showlisteners() {
    sudo ss -lnp
}

checkssh() {
    printf "Checking sshd config..."

    grep "PermitRootLogin" /etc/ssh/sshd_config
    grep "Port:" /etc/ssh/sshd_config
    grep "PAM" /etc/ssh/sshd_config
}

auditservices() {
    active_service_entries_log="$logDir/$(date | sed "s/_//g")active-service-entries"
    echo "$active_service_entries_log"
    touch "$active_service_entries_log"
    while read -r LINE; do
        sudo systemctl status $LINE >> "$active_service_entries_log"
        sudo systemctl status $LINE
    done < "$logDir/active-services"
}
getactiveservices
auditservices