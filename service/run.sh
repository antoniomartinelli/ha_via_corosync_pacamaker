#!/bin/bash
# IMPORTANT: This script is launched after the SystemD init

# Setup the client with nodes hostnames (ips can be used)
systemctl start pcsd
#(echo 'hacluster'; echo 'S!n;_8M^M?rDRyKD') | pcs cluster auth node_01 node_02
(echo 'S!n;_8M^M?rDRyKD') | pcs host auth node_01 node_02 -u hacluster

pcs cluster setup test_cluster node_01 node_02
pcs cluster start --all
pcs cluster enable --all

# disable stonith
pcs property set stonith-enabled=false
# disable quorum 
pcs property set no-quorum-policy=ignore
# set fail 
pcs property set start-failure-is-fatal=false

# Enable the custom service (Not needed if the service is used as RA by CS/PM) 
#systemctl enable shellscript.service

# Create floating ip resource (use an address in the same subnet)
pcs resource create floating_ip ocf:heartbeat:IPaddr2 ip=172.28.0.100 cidr_netmask=24 op monitor interval=30s
# Create a dummy nginx resource
pcs resource create webserver ocf:heartbeat:nginx configfile=/etc/nginx/nginx.conf op monitor timeout="5s" interval="5s"
# Create the custom resource
pcs resource create shellscript systemd:shellscript \
op monitor interval=30s \
op start timeout=180s \
op stop timeout=180s \
op status timeout=15

# Colocation and order constraints
pcs constraint colocation add webserver with floating_ip INFINITY
pcs constraint order floating_ip then webserver

pcs constraint colocation add shellscript with webserver INFINITY
pcs constraint order floating_ip then shellscript

# Add migration-threhsold (do not migrate until INFINITY failures are reached)
pcs resource meta shellscript migration-threshold=INFINITY

pcs cluster start --all
pcs cluster enable --all
