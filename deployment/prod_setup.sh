#!/bin/bash
# This setup script must be run as first on all the nodes of the cluster.

# *Optional* spel-release is usually pre-installed
#yum install epel-release -y

# Open port 2224/tcp on local firewall
firewall-cmd --zone=public --permanent --add-port 2224/tcp
firewall-cmd --reload
firewall-cmd --list-all

# Install Corosync and Pacemaker
sed -i 's/enabled=0/enabled=1/g' /etc/yum.repos.d/*-HighAvailability.repo
# yum update -y #don't update if not strictly needed
dnf install --assumeyes pacemaker corosync pcs which passwd
# corosync-keygen #it can come in handy if there are problem with authentication

# Change password for hacluster user
(echo 'S!n;_8M^M?rDRyKD'; echo 'S!n;_8M^M?rDRyKD') | passwd hacluster

# Enable services
systemctl enable pcsd
systemctl enable corosync
systemctl enable pacemaker

# Custom script as SystemD service
chmod +x shellscript.sh
cp shellscript.sh /tmp/shellscript.sh

# SystemD service wrapper for the custom script 
cp shellscript.service  /lib/systemd/system/.
# Enable the custom service (Not needed if the service is used as RA by CS/PM) 
#systemctl enable shellscript.service
