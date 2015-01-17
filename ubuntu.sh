#!/bin/bash

if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi

apt-get update


apt-get install -y git emacs24

# Dev stuff
apt-get install -y hardening-wrapper

