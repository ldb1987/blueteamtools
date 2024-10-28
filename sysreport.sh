#/bin/sh

logDir="$HOME/logs"

mkdir -p "$logDir"
grep -vE "nologin" /etc/passwd > "$logDir/users"

systemctl list-units --state=failed > "$logDir/failed-services"
who > tee "$logDir/logged-in"
printf "%s\n\n%s\n\n%s\n\n%s\n\n%s\n\n%s\n" "---Available Users---" "$(< $logDir/users)" "---Logged-In Users---" "$(< $logDir/logged-in)" "---Failed Services---" "$(< $logDir/failed-services)"
