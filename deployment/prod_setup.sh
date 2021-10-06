#!/bin/bash
# This setup script must be run as first on all the nodes of the cluster.

# Add hosts ip address
echo "192.168.8.173	dmcfa" >> /etc/hosts
echo "192.168.8.124	dmcfb" >> /etc/hosts

# Open port 2224/tcp on local firewall
#firewall-cmd --zone=public --permanent --add-port 2224/tcp
firewall-cmd --permanent --add-service=high-availability
firewall-cmd --add-service=high-availability
firewall-cmd --reload
firewall-cmd --list-all

# Install Corosync and Pacemaker
sed -i 's/enabled=0/enabled=1/g' /etc/yum.repos.d/*-HighAvailability.repo
# yum update -y #don't update if not strictly needed
dnf install --assumeyes pacemaker corosync pcs which passwd

# Change password for hacluster user
(echo 'S!n;_8M^M?rDRyKD'; echo 'S!n;_8M^M?rDRyKD') | passwd hacluster

# Enable services
systemctl enable pcsd
systemctl enable corosync
systemctl enable pacemaker
systemctl start pcsd

# Copy DMCF software files in /opt
# cp ../select/folder/ /opt/galsee

# Scripts as SystemD service
# copy services in systemd 
cp systemd_services/*  /lib/systemd/system/.

# Enabling services is not need if they are handled by pacemaker
systemctl enable dmcf_hw_monitoring_data.service
systemctl enable dmcf_uaf_monitoring.service 
systemctl enable dmcf_monitoring_data.service 
systemctl enable dmcf_data_to_uaf.service 

# Enable the services (not needed if the service is used as RA by CS/PM)
systemctl daemon-reload
