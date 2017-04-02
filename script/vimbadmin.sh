#!/bin/bash
# The perfect rootserver
# by shoujii | BoBBer446
# https://github.com/shoujii/perfectrootserver
# Big thanks to https://github.com/zypr/perfectrootserver
# Compatible with Debian 8.x (jessie)

#################################
##  DO NOT MODIFY, JUST DON'T! ##
#################################

#Enable debug:
set -x
vimbadmin() {
echo "${info} Installing Vimbadmin..." | awk '{ print strftime("[%H:%M:%S] |"), $0 }'

#Erstelle Datenbank
mysql --defaults-file=/etc/mysql/debian.cnf -e "CREATE DATABASE vimbadmin; GRANT ALL ON vimbadmin.* TO 'vimbadmin'@'localhost' IDENTIFIED BY '${VIMB_MYSQL_PASS}'; FLUSH PRIVILEGES;" >>/root/logs/stderror.log 2>&1 >>/root/logs/stdout.log

#Download Vimbadmin via Composer
apt-get -q -y --force-yes install git curl >>/root/logs/stderror.log 2>&1 >>/root/logs/stdout.log
cd ~/sources
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('SHA384', 'composer-setup.php') === '669656bab3166a7aff8a7506b8cb2d1c292f042046c5a994c43155c0be6190fa0355160742ab2e1c88d40d5be660b410') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"
mv composer.phar /usr/local/bin/composer
composer create-project opensolutions/vimbadmin /srv/vimbadmin -s dev -n --keep-vcs

chown -R www-data: /srv/vimbadmin/public
chown -R www-data: /srv/vimbadmin/var
chown -R www-data: /srv/vimbadmin/
ln -s /srv/vimbadmin/public/ /etc/nginx/html/${MYDOMAIN}/vma >>/root/logs/stderror.log 2>&1 >>/root/logs/stdout.log

#Ändere Werte in der Vimbadmin Conf
cp /srv/vimbadmin/application/configs/application.ini.dist /srv/vimbadmin/application/configs/application.ini


#EMPTY!
#In der dovecot.sh wird das passwort eingetragen /etc/dovecot/dovecot-mysql.conf
#In der Mailfilter.sh auch /etc/amavis/conf.d/50-user
# In der postfix.sh wird es auch richtig eingetragen /etc/postfix/mysql/postfix-mysql-virtual_alias_maps.cf
echo "Vimbadmin passwort:" 
echo ${VIMB_MYSQL_PASS}
#sed -i "s/resources.doctrine2.connection.options.password = \"xxx\"/resources.doctrine2.connection.options.password = \"${VIMB_MYSQL_PASS}\"/g" /srv/vimbadmin/application/configs/application.ini

sed -i "s/xxx/${VIMB_MYSQL_PASS}/g" /srv/vimbadmin/application/configs/application.ini


# Passt, die line gibt es aber jetzt 2x
sed -i 's/defaults.mailbox.uid = 2000/defaults.mailbox.uid = 5000/g' /srv/vimbadmin/application/configs/application.ini


#gibt es nicht!
#Muss eingefügt werden
#sed -i 's/defaults.mailbox.gid = 2000/defaults.mailbox.uid = 5000/g' /srv/vimbadmin/application/configs/application.ini
echo -e 'defaults.mailbox.uid = 5000' >> /srv/vimbadmin/application/configs/application.ini


# Ausgabe in der File: defaults.mailbox.maildir = "maildir:/var/vmail/%d/%u/Maildir:LAYOUT=fs"
sed -i 's/defaults.mailbox.maildir = "maildir:\/srv\/vmail\/%d\/%u\/mail:LAYOUT=fs"/defaults.mailbox.maildir = "maildir:\/var\/vmail\/%d\/%u\/Maildir:LAYOUT=fs"/g' /srv/vimbadmin/application/configs/application.ini

#Ausgabe in der file: defaults.mailbox.homedir = "/var/vmail/%d/%u"
sed -i 's/defaults.mailbox.homedir = "\/srv\/vmail\/%d\/%u"/defaults.mailbox.homedir = "\/var\/vmail\/%d\/%u"/g' /srv/vimbadmin/application/configs/application.ini

#Ausgabe in der file: defaults.mailbox.password_scheme = "dovecot:SHA512-CRYPT"
sed -i 's/defaults.mailbox.password_scheme = "dovecot:BLF-CRYPT"/defaults.mailbox.password_scheme = "dovecot:SHA512-CRYPT"/g' /srv/vimbadmin/application/configs/application.ini

#Ausgabe in der File: mailbox_deletion_fs_enabled = true
sed -i 's/mailbox_deletion_fs_enabled = false/mailbox_deletion_fs_enabled = true/g' /srv/vimbadmin/application/configs/application.ini

#Ausagbe in der File: server.smtp.port    = "587" ----> Port in firewall nötig?
sed -i 's/server.smtp.port    = "465"/server.smtp.port    = "587"/g' /srv/vimbadmin/application/configs/application.ini

#gibt es nicht!
#Muss eingefügt werden
#sed -i 's/server.smtp.crypt   = "SSL"/server.imap.crypt = "TLS"/g' /srv/vimbadmin/application/configs/application.ini
echo -e 'server.imap.crypt = "TLS"' >> /srv/vimbadmin/application/configs/application.ini
#Ausgabe in der File: server.imap.host  = "mail.%d" -------------> Passt!
sed -i 's/server.imap.host  = "gpo.%d"/server.imap.host  = "mail.%d"/g' /srv/vimbadmin/application/configs/application.ini

#Ausgabe in der file: server.imap.port  = "143" -------------> Passt!
sed -i 's/server.imap.port  = "993"/server.imap.port  = "143"/g' /srv/vimbadmin/application/configs/application.ini

#Ausgabe in der file: server.imap.crypt = "TLS" -------------> Passt!
sed -i 's/server.imap.crypt = "SSL"/server.imap.crypt = "TLS"/g' /srv/vimbadmin/application/configs/application.ini

# Ausgabe in der File: server.webmail.host  = "https://mail.%d/webmail" ------> da muss wohl noch ${MYDOMAIN} dazu oder?
sed -i "s/server.webmail.host  = \"https:\/\/webmail.%d\"/server.webmail.host  = \"https:\/\/mail.%d\/webmail\"/g" /srv/vimbadmin/application/configs/application.ini

#Ausgabe in der file: server.pop3.enabled = 0 -------------> Passt!
sed -i "s/server.pop3.enabled = 1/server.pop3.enabled = 0/g" /srv/vimbadmin/application/configs/application.ini

#Ausgabe in der file: defaults.domain.transport = "virtual" -------------> Passt!
sed -i "s/defaults.domain.transport = \"virtual\"\/defaults.domain.transport = \"lmtps:unix:private\/dovecot-lmtp\"/g" /srv/vimbadmin/application/configs/application.ini


sed -i "s/example.com/${MYDOMAIN}/g" /srv/vimbadmin/application/configs/application.ini

mkdir -p /srv/archives
cp /srv/vimbadmin/public/.htaccess.dist /srv/vimbadmin/public/.htaccess

cd /srv/vimbadmin/
./bin/doctrine2-cli.php orm:schema-tool:create

#nano /srv/vimbadmin/application/configs/application.ini
#muss manuell gemacht werden mit dem eintragen

echo "${info} Installing Crontabs..." | awk '{ print strftime("[%H:%M:%S] |"), $0 }'
(crontab -l && echo "# Die 10. Minute jeder 2. Stunde") | crontab -
(crontab -l && echo "10 */2 * * * /srv/vimbadmin/bin/vimbtool.php -a archive.cli-archive-pendings") | crontab -
(crontab -l && echo "# Die 30. Minute jeder 2. Stunde") | crontab -
(crontab -l && echo "30 */2 * * * /srv/vimbadmin/bin/vimbtool.php -a archive.cli-restore-pendings") | crontab -
(crontab -l && echo "# Die 50. Minute jeder 2. Stunde") | crontab -
(crontab -l && echo "50 */2 * * * /srv/vimbadmin/bin/vimbtool.php -a archive.cli-delete-pendings") | crontab -
(crontab -l && echo "# 3:15 AM") | crontab -
(crontab -l && echo "15 3 * * * /srv/vimbadmin/bin/vimbtool.php -a mailbox.cli-delete-pending") | crontab -


# Wohin das cert?
# Neu erstellen oder bei nginx dazu packen, wenn mailserver?
cat > /etc/nginx/sites-custom/vimbadmin.conf <<END
location ~ ^/vma {
    alias /srv/vimbadmin/public;

    location ~ ^/vma/(.*\.(js|css|gif|jpg|png|ico))$ {
        alias /srv/vimbadmin/public/$1;
    }

    rewrite ^/vma(.*)$ /vma/index.php last;

    location ~ ^/vma(.+\.php)$ {
        alias /srv/vimbadmin/public$1;
        fastcgi_pass unix:/var/run/php7.0-fpm.sock;
        fastcgi_index index.php;
        charset utf8;
        include fastcgi_params;
        fastcgi_param DOCUMENT_ROOT /srv/vimbadmin/public;
    }
}
END

#Restarting Services
echo "${info} Restarting Services..." | awk '{ print strftime("[%H:%M:%S] |"), $0 }'
if [ ${USE_PHP7} == '1' ]; then
		systemctl restart {dovecot,postfix,amavis,spamassassin,clamav-daemon,nginx,php7.0-fpm,mysql} >>/root/logs/stderror.log 2>&1 >>/root/logs/stdout.log
fi
	
if [ ${USE_PHP5} == '1' ]; then
		systemctl restart {dovecot,postfix,amavis,spamassassin,clamav-daemon,nginx,php5-fpm,mysql} >>/root/logs/stderror.log 2>&1 >>/root/logs/stdout.log
fi
}
source ~/configs/userconfig.cfg