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

##### Scripts as SystemD service
# Custom Service 1
#chmod +x shellscript.sh
#cp shellscript.sh /tmp/shellscript.sh
#cp shellscript.service  /lib/systemd/system/.
#systemctl enable shellscript.service

# Service monitoring_data.py
# chmod +x Monitoring_data.py
cp monitoring_data.service  /lib/systemd/system/.
systemctl enable monitoring_data.service

# Service HW_monitoring.py
# chmod +x HW_monitoring.sh
cp hw_monitoring.service  /lib/systemd/system/.
systemctl enable hw_monitoring.service 

# Enable the services (not needed if the service is used as RA by CS/PM)
systemctl daemon-reload
