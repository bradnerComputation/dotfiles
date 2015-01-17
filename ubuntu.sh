#!/bin/bash

if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi

# Where am I?
SCRIPT=$(readlink -f $0)
SCRIPTPATH=`dirname $SCRIPT`

apt-get update

# Things I *hate*
# apt-get purge 

# Utilities
apt-get install -y aptitude screen tmux htop iotop iftop

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


#### Syscyl
cp $SCRIPTPATH/conf/ubuntu/sysctl.d/*.conf /etc/sysctl.d/
service procps restart

#### Sudoers
# Via: http://www.chromium.org/chromium-os/tips-and-tricks-for-chromium-os-developers
cd /tmp
cat > ./sudo_editor <<EOF
EOF
#!/bin/sh
echo Defaults \!tty_tickets > \$1          # Entering your password in one shell affects all shells
echo Defaults timestamp_timeout=120 >> \$1 # Time between re-requesting your password, in minutes
EOF
chmod +x ./sudo_editor
sudo EDITOR=./sudo_editor visudo -f /etc/sudoers.d/relax_requirements
EOF

#### Mount tweaks


#### Generate ssh-key if missing


### Grub text-only boot mode


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
