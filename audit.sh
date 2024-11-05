#/bin/sh

logDir="$HOME/logs"

mkdir -p "$logDir"
grep -vE "nologin" /etc/passwd > "$logDir/users"

systemctl list-units --state=failed > "$logDir/failed-services"
who > "$logDir/logged-in"
printf "%s\n\n%s\n\n%s\n\n%s\n\n%s\n\n%s\n" "---Available Users---" "$(< $logDir/users)" "---Logged-In Users---" "$(< $logDir/logged-in)" "---Failed Services---" "$(< $logDir/failed-services)"

getactiveservices() {
    systemctl list-units --state=active | tee
}

getfailedservices() {
    systemctl list-units --state=failed | tee
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