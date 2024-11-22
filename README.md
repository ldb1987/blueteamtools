For storing blue team tools & scripts.
These scripts are not good please don't use them.


--fw.sh--

    Script for creating deny-by-default firewall rules. Has a global set of rules allowing outbound traffic to ports 80, 443, and 53 to allow DNS, package managers, and internet access; all forwarding is blocked by default.

    Options exist for more specific rules on top of those:
        -h: show help
        -p: Allows traffic for webservers by allowing new connections inbound to ports 80 and 443
        -w: Allows traffic for SMTP and IMAP
        -v: Allows FTP traffic inbound to port 21 and ftp-data traffic outbound from port 20. As a result, it currently only allows active mode to function.
        -r: reset; clears all firewalls rules and chains created by this script and sets all default chain policies to accept
        -s: save current rules


--restore2.sh--

    Allow backing up and restoring config files for certain services; currently only apache (httpd), sshd (openssh-server), postfix, and dovecot, as well as reinstalling packages.

    Options:
        -h: show help
        -b [comma-separated list of services] [Optional backup directory path]: Backup configs for certain services to a directory, which can be optionally specified

        -i [comma-separated list of services]: reinstall and restore configs for services. Assumes backups already exist
        -r [comma-separated list of services] [Optional backup directory path]: restore configs for services from backups. Assumes backups already exist


--pass2.sh--

    randomly generate and reset passwords of a hard-coded list of users

    Options:
        -s: show generated password for each user


--audit.sh--

    Script to show some system information.

    Options:
        -h: show help
        -s: log service files for all active services, and display them to the user one-by-one for detailed auditing
        -u: show currently logged-in users
        -a: list all users on the system not on the list of authorized users
        -l: list listening sockets
        -r: list netcat processes
        -n: show networking information