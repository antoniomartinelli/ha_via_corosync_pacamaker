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
pcs resource create floating_ip ocf:heartbeat:IPaddr2 ip=$dmcf_floating_ip cidr_netmask=24 \
op monitor interval=30s

pcs resource create dmcf_hw_monitoring systemd:dmcf_hw_monitoring \
op monitor interval=30s \
op start timeout=180s \
op stop timeout=180s \
op status timeout=15

pcs resource create dmcf_uaf_monitoring systemd:dmcf_uaf_monitoring \
op monitor interval=30s \
op start timeout=180s \
op stop timeout=180s \
op status timeout=15

pcs resource create dmcf_monitoring_data systemd:dmcf_monitoring_data \
op monitor interval=30s \
op start timeout=180s \
op stop timeout=180s \
op status timeout=15

pcs resource create dmcf_data_to_uaf systemd:dmcf_data_to_uaf \
op monitor interval=30s \
op start timeout=180s \
op stop timeout=180s \
op status timeout=15

pcs resource create crond systemd:crond \
op monitor interval=30s \
op start timeout=180s \
op stop timeout=180s \
op status timeout=15

# Colocation Constraints
pcs constraint colocation add dmcf_hw_monitoring with floating_ip INFINITY
pcs constraint order floating_ip then dmcf_hw_monitoring

pcs constraint colocation add dmcf_uaf_monitoring with floating_ip INFINITY
pcs constraint order floating_ip then dmcf_uaf_monitoring

pcs constraint colocation add dmcf_monitoring_data with floating_ip INFINITY
pcs constraint order floating_ip then dmcf_monitoring_data
pcs constraint order dmcf_hw_monitoring then dmcf_monitoring_data
pcs constraint order dmcf_uaf_monitoring then dmcf_monitoring_data

pcs constraint colocation add dmcf_data_to_uaf with floating_ip INFINITY
pcs constraint order floating_ip then dmcf_data_to_uaf

pcs constraint colocation add crond with floating_ip INFINITY
pcs constraint order floating_ip then crond

# Location Constraints
pcs constraint location floating_ip prefer dmcfa


pcs cluster start --all
pcs cluster enable --all
