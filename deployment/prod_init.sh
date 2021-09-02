#!/bin/bash
# This initialization script needs to be launched one time, 
# only on a single node of the cluster.

# Define DMCF floating IP address
dmcf_floating_ip=192.168.8.100

# Setup the client with nodes hostnames (ips can be used)
(echo 'S!n;_8M^M?rDRyKD') | pcs host auth dmcfa dmcfb -u hacluster

pcs cluster setup dmcf_cluster dmcfa dmcfb
pcs cluster start --all
pcs cluster enable --all

# disable stonith
pcs property set stonith-enabled=false
# disable quorum 
pcs property set no-quorum-policy=ignore

# Create floating ip resource (use an address in the same subnet)
pcs resource create floating_ip ocf:heartbeat:IPaddr2 \
	ip=$dmcf_floating_ip cidr_netmask=24 \
	op monitor interval=30s

# # Create the mysql resource (Not needed)
# pcs resource create mysql ocf:heartbeat:mysql \
#   params binary="/usr/sbin/mysqld" \
#          datadir="/var/lib/mysql1" \
#          pid="/var/run/mysqld/mysql1.pid" \
#          socket="/var/run/mysqld/mysql1.sock" \
#          log="/var/run/mysqld/mysql1.log" \
#          additional_parameters="--bind-address=192.168.122.109" \
#   op start timeout=180s \
#   op stop timeout=180s \
#   op monitor timeout=30s interval=10s


# Create the custom resource 1
#pcs resource create shellscript systemd:shellscript \
#op monitor interval=30s \
#op start timeout=180s \
#op stop timeout=180s \
#op status timeout=15s

# Create the monitoring_data resource
pcs resource create monitoring_data systemd:monitoring_data \
op monitor interval=30s \
op start timeout=180s \
op stop timeout=180s \
op status timeout=15s

# Create the hw_monitoring resource
pcs resource create hw_monitoring systemd:hw_monitoring \
op monitor interval=30s \
op start timeout=180s \
op stop timeout=180s \
op status timeout=15s

# Colocation and order constraints
#pcs constraint colocation add shellscript with floating_ip INFINITY
pcs constraint colocation add monitoring_data with floating_ip INFINITY
pcs constraint colocation add hw_monitoring with floating_ip INFINITY
pcs constraint order floating_ip then monitoring_data
pcs constraint order floating_ip then hw_monitoring

pcs cluster start --all
pcs cluster enable --all
