#!/bin/bash
# The perfect rootserver
# by shoujii | BoBBer446
# This is an standalone addonscript for 
# https://github.com/shoujii/perfectrootserver

SSL_PATH_VSFTPD="/etc/ssl/private"
RSA_KEY_VSFTPD="2048"
MYDOMAIN="meinedomain.tld"
FTP_USERNAME="meinftpuser"
PATH_TO_WEBFOLDER="/etc/nginx/html"
FTP_USER_GROUP="wwwftp"


##########################################################################
###################### DO NOT EDIT ANYTHING BELOW! #######################
##########################################################################

# Some nice colors
red() { echo "$(tput setaf 1)$*$(tput setaf 9)"; }
green() { echo "$(tput setaf 2)$*$(tput setaf 9)"; }
yellow() { echo "$(tput setaf 3)$*$(tput setaf 9)"; }
magenta() { echo "$(tput setaf 5)$*$(tput setaf 9)"; }
cyan() { echo "$(tput setaf 6)$*$(tput setaf 9)"; }
textb() { echo $(tput bold)${1}$(tput sgr0); }
greenb() { echo $(tput bold)$(tput setaf 2)${1}$(tput sgr0); }
redb() { echo $(tput bold)$(tput setaf 1)${1}$(tput sgr0); }
yellowb() { echo $(tput bold)$(tput setaf 3)${1}$(tput sgr0); }
pinkb() { echo $(tput bold)$(tput setaf 5)${1}$(tput sgr0); }

# Some nice variables
info="$(textb [INFO] -)"
warn="$(yellowb [WARN] -)"
error="$(redb [ERROR] -)"
fyi="$(pinkb [INFO] -)"
ok="$(greenb [OKAY] -)"

echo
echo
echo "$(date +"[%T]") | $(textb +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+)"
echo "$(date +"[%T]") |  $(textb Very) $(textb Secure) $(textb FTP) $(textb deamon) $(textb vsFTPd)"
echo "$(date +"[%T]") | $(textb +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+)"
echo
echo "$(date +"[%T]") | ${info} Welcome to the Perfect Rootserver installation!"
echo "$(date +"[%T]") | ${info} This script deinstall FTP Service"
echo "$(date +"[%T]") | ${info} Please wait while the deinstaller is preparing for the first use..."

# --------------------------------------------------------------------------------------------------------------------------------------------------

echo "${info} Start deinstallation von VSFTPD..." | awk '{ print strftime("[%H:%M:%S] |"), $0 }'

apt-get purge -y vsftpd
rm -rf $SSL_PATH_VSFTPD/vsftpd.pem
rm -rf /etc/vsftpd.conf
rm -rf /root/VSFTP_LOGINDATA.txt
userdel $FTP_USERNAME
groupdel $FTP_USER_GROUP

#TODO:
# Remove Ports from Firewall

echo "${info} Restart Services." | awk '{ print strftime("[%H:%M:%S] |"), $0 }'
	systemctl -q restart sshd
	systemctl force-reload arno-iptables-firewall.service