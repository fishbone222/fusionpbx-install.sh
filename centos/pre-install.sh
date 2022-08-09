#!/bin/sh

#install git
dnf -y install git
dnf config-manager --set-enabled powertools -y

#get the install script
cd /usr/src && git clone https://github.com/fishbone222/fusionpbx-install.sh.git

#change the working directory
cd /usr/src/fusionpbx-install.sh/centos
