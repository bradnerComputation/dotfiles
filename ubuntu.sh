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


#### Hardening tweaks
echo -e "${GREEN}Hardening sshd and ssh${NOCOLOR}" && sleep 3



#### Ramdisk creation


### Auto updates
dpkg-reconfigure -plow unattended-upgrades


exit


#### Ubuntu UX/UI/Privacy tweaks
# Derived from:
# https://blogs.fsfe.org/the_unconventional/2015/01/14/improving-ubuntu-privacy/

# Automount
# gsettings set org.gnome.desktop.media-handling automount false
# gsettings set org.gnome.desktop.media-handling automount-open false
# gsettings set org.gnome.desktop.media-handling autorun-never true

# Keyboard indicator
gsettings set com.canonical.indicator.keyboard visible false

# HUD
gsettings set com.canonical.indicator.appmenu.hud store-usage-data false

# Disable search scopes
gsettings set com.canonical.Unity.Dash scopes "['applications.scope']"
gsettings set com.canonical.Unity.Lenses always-search "['applications.scope']"
gsettings set com.canonical.Unity.Lenses home-lens-default-view "['applications.scope']"
gsettings set com.canonical.Unity.Lenses home-lens-priority "['applications.scope']"
gsettings set com.canonical.Unity.Lenses remote-content-search none

# Disable app suggestions
gsettings set com.canonical.Unity.ApplicationsLens display-available-apps false

# No recently used
gsettings set org.gnome.desktop.privacy remember-app-usage false
gsettings set org.gnome.desktop.privacy remember-recent-files false



####
# Install APT things
####

echo "Starting apt package installs, etc."
sleep 3

apt-get update

# Things I *hate*
# apt-get purge 

# Utilities
apt-get install -y aptitude screen tmux htop iotop iftop acct

# Things I like
apt-get install -y git emacs24 mosh

# Dev/building stuff
apt-get install -y build-essential ccache gdb 

# Python3
apt-get install -y python3 pep8 pylint

# Webdeb things
apt-get install -y optipng pngcrush jpegoptim

# Security-focused things
apt-get install -y hardening-wrapper fail2ban nmap


# Clean a bit
apt-get autoremove
apt-get autoclean

