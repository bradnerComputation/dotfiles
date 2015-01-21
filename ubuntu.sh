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
echo -e "${GREEN}Updating sysctl${NOCOLOR}" && sleep 2

cp $SCRIPTPATH/conf/ubuntu/sysctl.d/*.conf /etc/sysctl.d/
service procps restart

#### FIDO U2F Tokens
echo -e "${GREEN}Udev rules for FIDO${NOCOLOR}" && sleep 2
cp $SCRIPTPATH/conf/ubuntu/50-fido.rules /etc/udev/rules.d/
						
#### Sudoers
# Via: http://www.chromium.org/chromium-os/tips-and-tricks-for-chromium-os-developers
# TODO: Check this is actually included?
echo -e "${GREEN}Relaxing sudoers${NOCOLOR}" && sleep 2

EDITOR=$SCRIPTPATH/conf/ubuntu/sudo_editor visudo -f /etc/sudoers.d/relax_requirements


#### Grub text-only boot mode
echo -e "${GREEN}Setting grub text-only and trim on dm-crypt${NOCOLOR}" && sleep 2

cp /etc/default/grub /etc/default/grub.old
cp $SCRIPTPATH/conf/ubuntu/grub /etc/default/grub
update-grub


#### Mount tweaks
# echo "Setting mount tweaks" && sleep 2


#### Generate ssh-key if missing
echo -e "${GREEN}Generating ssh-key for device${NOCOLOR}" && sleep 2
if [ ! -f "/home/${REALUSER}/.ssh/id_rsa" ]; then
    su ${REALUSER} -c 'ssh-keygen -b 4096 -C "$(whoami)@$(hostname)-$(date -I)"'
else
    echo "Key already exists" && sleep 2
fi


#### SSH tweaks
echo -e "${GREEN}Hardening sshd and ssh${NOCOLOR}" && sleep 2


#### Ramdisk creation
echo -e "${GREEN}Ramdisk creation${NOCOLOR}" && sleep 2


### Auto updates
echo -e "${GREEN}Enabling auto updates?${NOCOLOR}" && sleep 2
dpkg-reconfigure -plow unattended-upgrades


#### Ubuntu UX/UI/Privacy tweaks
echo -e "${GREEN}Tweaking ubuntu UI settings as user...${NOCOLOR}" && sleep 2
su ${REALUSER} -c "${SCRIPTPATH}/conf/ubuntu/gsettings-tweaks.sh"


####
# Install APT things
####

echo "Starting apt package installs, etc."
sleep 2


apt-add-repository -y "deb http://repository.spotify.com stable non-free"
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 94558F59

apt-get update -qq

# Things I *hate*
apt-get purge -y unity-webapps-common

# Utilities
apt-get install -y aptitude screen tmux htop iotop iftop acct smartmontools

# Things I like
apt-get install -y git emacs24 mosh xpad spotify-client

# Dev/building stuff
apt-get install -y build-essential ccache gdb npm nodejs-legacy 

# Python3
apt-get install -y python3 pep8 pylint python3-pip python-pip ipython ipython3

# Webdeb things
apt-get install -y optipng pngcrush jpegoptim

# Security-focused things
apt-get install -y hardening-wrapper fail2ban

# Network focused things
apt-get install -y nmap ngrep wireshark

# Clean a bit
apt-get autoremove
apt-get autoclean

