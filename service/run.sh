#!/bin/bash

# Setup the client with nodes hostnames (ips can be used)
systemctl start pcsd
(echo 'hacluster'; echo 'somepassword') | pcs cluster auth service_01 service_02
pcs cluster setup --name test_cluster service_01 service_02
pcs cluster start --all
pcs cluster enable --all

# disable stonith
pcs property set stonith-enabled=false
# disable quorum 
pcs property set no-quorum-policy=ignore

# Create floating ip (use an address in the same subnet)
pcs resource create floating_ip ocf:heartbeat:IPaddr2 ip=172.28.0.100 cidr_netmask=24 op monitor interval=30s
# Create a dummy nginx service
pcs resource create webserver ocf:heartbeat:nginx configfile=/etc/nginx/nginx.conf op monitor timeout="5s" interval="5s"

# Colocation and order constraints
pcs constraint colocation add webserver floating_ip INFINITY
pcs constraint order floating_ip then webserver

pcs cluster start --all
pcs cluster enable --all
