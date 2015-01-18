#!/bin/bash

GREEN='\033[0;32m'
NOCOLOR='\033[0m'
echo -e "${GREEN}Prepping a new machine!${NOCOLOR}"

if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi

# Where am I?
SCRIPT=$(readlink -f $0)
SCRIPTPATH=`dirname $SCRIPT`
# Who am I, really?
REALUSER=`logname`

#### Sysctl tweaks
echo -e "${GREEN}Updating sysctl${NOCOLOR}" && sleep 3

cp $SCRIPTPATH/conf/ubuntu/sysctl.d/*.conf /etc/sysctl.d/
service procps restart


#### Sudoers
# Via: http://www.chromium.org/chromium-os/tips-and-tricks-for-chromium-os-developers
# TODO: Check this is actually included?
echo -e "${GREEN}Relaxing sudoers${NOCOLOR}" && sleep 3

EDITOR=$SCRIPTPATH/conf/ubuntu/sudo_editor visudo -f /etc/sudoers.d/relax_requirements


#### Grub text-only boot mode
echo -e "${GREEN}Setting grub text-only and trim on dm-crypt${NOCOLOR}" && sleep 3

cp /etc/default/grub /etc/default/grub.old
cp $SCRIPTPATH/conf/ubuntu/grub /etc/default/grub
update-grub


#### Mount tweaks
# echo "Setting mount tweaks" && sleep 3


#### Generate ssh-key if missing
echo -e "${GREEN}Generating ssh-key for device${NOCOLOR}" && sleep 3
if [ ! -f "/home/${REALUSER}/.ssh/id_rsa" ]; then
    su ${REALUSER} -c 'ssh-keygen -b 4096 -C "$(whoami)@$(hostname)-$(date -I)"'
else
    echo "Key already exists" && sleep 2
fi


#### SSH tweaks
echo -e "${GREEN}Hardening sshd and ssh${NOCOLOR}" && sleep 3


#### Ramdisk creation
echo -e "${GREEN}Ramdisk creation${NOCOLOR}" && sleep 3


### Auto updates
echo -e "${GREEN}Enabling auto updates?${NOCOLOR}" && sleep 3
dpkg-reconfigure -plow unattended-upgrades


#### Ubuntu UX/UI/Privacy tweaks
echo -e "${GREEN}Tweaking ubuntu UI settings as user...${NOCOLOR}" && sleep 3
su ${REALUSER} -c "${SCRIPTPATH}/conf/ubuntu/gsettings-tweaks.sh"


####
# Install APT things
####

echo "Starting apt package installs, etc."
sleep 3

apt-get update

# Things I *hate*
apt-get purge unity-webapps-common

# Utilities
apt-get install -y aptitude screen tmux htop iotop iftop acct

# Things I like
apt-get install -y git emacs24 mosh xpad

# Dev/building stuff
apt-get install -y build-essential ccache gdb npm 

# Python3
apt-get install -y python3 pep8 pylint

# Webdeb things
apt-get install -y optipng pngcrush jpegoptim

# Security-focused things
apt-get install -y hardening-wrapper fail2ban

# Network focused things
apt-get install -y nmap ngrep wireshark

# Clean a bit
apt-get autoremove
apt-get autoclean

