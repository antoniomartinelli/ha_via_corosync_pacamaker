# HA Cluster via Corosync/Pacemaker
A cluter of the nodes runs a floating ip service and an nginx service. Both nodes are reachable with a shared floating ip. The nginx service is highly available via an active/passive failover paradigm. Docker is used to containerize the system.

## Instructions
1. *start.sh*
2. Access to service\_01 shell via *docker exec -ti service_01 /bin/bash* (It can be done with any node)
3. In service\_01 launch *run.sh* that setup the cluster and the services
4. Test the availability of the web service on 172.28.0.100


## Useful commands for monitoring the cluster

```bash
pcs status

pcs status corosync

corosync-cmapctl | grep members

pcs status nodes

pcs cluster stop service_01

pcs resource move resource_id [destination_node]
```

## Resources

* https://www.howtoforge.com/tutorial/how-to-set-up-nginx-high-availability-with-pacemaker-corosync-on-centos-7/

* https://www.howtoforge.com/tutorial/how-to-set-up-nginx-high-availability-with-pacemaker-corosync-and-crmsh-on-ubuntu-1604/

* https://github.com/pschiffe/pcs
