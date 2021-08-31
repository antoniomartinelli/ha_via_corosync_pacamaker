#!/bin/bash
# IMPORTANT: This script is launched after the SystemD init

# Setup the client with nodes hostnames (ips can be used)
systemctl start pcsd
(echo 'hacluster'; echo 'somepassword') | pcs cluster auth node_01 node_02
pcs cluster setup --name test_cluster node_01 node_02
pcs cluster start --all
pcs cluster enable --all

# disable stonith
pcs property set stonith-enabled=false
# disable quorum 
pcs property set no-quorum-policy=ignore

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
pcs constraint colocation add webserver floating_ip INFINITY
pcs constraint order floating_ip then webserver

pcs constraint colocation add shellscript webserver INFINITY
pcs constraint order floating_ip then shellscript


pcs cluster start --all
pcs cluster enable --all
