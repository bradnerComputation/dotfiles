#!/bin/bash

#### Ubuntu UX/UI/Privacy tweaks
# Derived from:
# https://blogs.fsfe.org/the_unconventional/2015/01/14/improving-ubuntu-privacy/

# FYI: there are *tons* of settings visible in dconf-editor

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

# Screensaver
gsettings set org.gnome.desktop.session idle-delay 300
gsettings set org.gnome.desktop.screensaver lock-delay 0
gsettings set org.gnome.desktop.screensaver lock-enabled true
gsettings set org.gnome.desktop.screensaver idle-activation-enabled true

