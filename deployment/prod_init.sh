#!/bin/bash
# This initialization script needs to be launched one time, 
# only on a single node of the cluster.

# Define DMCFs IPs
dmcf_a=localhost
dmcf_b=localhost
dmcf_floating_ip=127.0.0.1

# Setup the client with nodes hostnames (ips can be used)
systemctl start pcsd
(echo 'S!n;_8M^M?rDRyKD') | pcs host auth $dmcf_a $dmcf_b -u hacluster

pcs cluster setup dmcf_cluster $dmcf_a $dmcf_b
pcs cluster start --all
pcs cluster enable --all

# disable stonith
pcs property set stonith-enabled=false
# disable quorum 
pcs property set no-quorum-policy=ignore

# Create floating ip resource (use an address in the same subnet)
pcs resource create floating_ip ocf:heartbeat:IPaddr2 ip=$dmcf_floating_ip cidr_netmask=24 \
op monitor interval=30s

# Create the custom resource
pcs resource create shellscript systemd:shellscript \
op monitor interval=30s \
op start timeout=180s \
op stop timeout=180s \
op status timeout=15

# Colocation and order constraints
pcs constraint colocation add shellscript with floating_ip INFINITY
pcs constraint order floating_ip then shellscript

pcs cluster start --all
pcs cluster enable --all
