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
echo -e "${GREEN}Updating sysctl${NOCOLOR}" && sleep 1
cp $SCRIPTPATH/conf/ubuntu/sysctl.d/*.conf /etc/sysctl.d/
service procps restart

#### FIDO U2F Tokens and USB devices
echo -e "${GREEN}Udev rules for FIDO and USB${NOCOLOR}" && sleep 1
cp $SCRIPTPATH/conf/ubuntu/50-udev.rules /etc/udev/rules.d/
						
#### Sudoers
# Via: http://www.chromium.org/chromium-os/tips-and-tricks-for-chromium-os-developers
# TODO: Check this is actually included?
echo -e "${GREEN}Relaxing sudoers${NOCOLOR}" && sleep 1

EDITOR=$SCRIPTPATH/conf/ubuntu/sudo_editor visudo -f /etc/sudoers.d/relax_requirements


#### Grub text-only boot mode
echo -e "${GREEN}Setting grub text-only and trim on dm-crypt${NOCOLOR}" && sleep 1

cp /etc/default/grub /etc/default/grub.old
cp $SCRIPTPATH/conf/ubuntu/grub /etc/default/grub
update-grub


#### Mount tweaks
# echo "Setting mount tweaks" && sleep 1

# TODO: Include discard/trim options, noatime, etc.



#### Generate SSH keys if missing
echo -e "${GREEN}Generating ssh-key for device${NOCOLOR}" && sleep 1

if [ ! -f "/home/${REALUSER}/.ssh/id_rsa" ]; then
    su ${REALUSER} -c 'ssh-keygen -t rsa -b 4096 -o -a 100 -C "$(whoami)@$(hostname)-$(date -I)"'
else
    echo "RSA Key already exists" && sleep 1
fi

if [ ! -f "/home/${REALUSER}/.ssh/id_ed25519" ]; then
    su ${REALUSER} -c 'ssh-keygen -t ed25519 -o -a 100 -C "$(whoami)@$(hostname)-$(date -I)"'
else
    echo "ED25519 Key already exists" && sleep 1
fi


#### SSH tweaks
echo -e "${GREEN}Hardening sshd and ssh${NOCOLOR}" && sleep 1

# TODO: Copy over ssh config w/ perferred ciphers, restrict root, etc.


#### Ramdisk creation
echo -e "${GREEN}Ramdisk creation${NOCOLOR}" && sleep 1

# TODO For chrome, or just update chrome pointers


### Auto updates
echo -e "${GREEN}Enabling auto updates?${NOCOLOR}" && sleep 1
dpkg-reconfigure -plow unattended-upgrades


#### Ubuntu UX/UI/Privacy tweaks
echo -e "${GREEN}Tweaking ubuntu UI settings as user...${NOCOLOR}" && sleep 1
su ${REALUSER} -c "${SCRIPTPATH}/conf/ubuntu/gsettings-tweaks.sh"


####
# Install APT things
####

echo "Starting apt package installs, etc."
sleep 1


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
apt-get install -y build-essential ccache gdb npm nodejs-legacy optipng pngcrush jpegoptim

# Python3
apt-get install -y python3 pep8 pylint python3-pip python-pip ipython ipython3

# Security-focused things
apt-get install -y hardening-wrapper fail2ban netplug libpam-google-authenticator nmap ngrep wireshark

# Clean a bit
apt-get autoremove
apt-get autoclean


## Configure netplug
echo -e "${GREEN}Netplug config${NOCOLOR}" && sleep 1
cp $SCRIPTPATH/conf/ubuntu/netplug/* /etc/netplug/
service netplug restart

## Harden lightdm
echo -e "${GREEN}Lightdm guest restriction${NOCOLOR}" && sleep 1
cp $SCRIPTPATH/conf/ubuntu/50-lightdm-lockdown.conf /usr/share/lightdm/lightdm.conf.d/

