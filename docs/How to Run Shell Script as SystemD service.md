# How to Run Shell Scripts as SystemD services and as Corosync/Pacamaker Resource Agents

1. Create the script and make it executable

```bash
vi /home/shellscript.sh 
chmod +x /home/shellscript.sh 
```

2. Create a SystemD File

```bash
vi /lib/systemd/system/shellscript.service 
```

*shellscript.service*:
```
[Unit]
Description=My Shell Script

[Service]
ExecStart=/home/shellscript.sh

[Install]
WantedBy=multi-user.target
```

3. Enable the service
```bash
systemctl daemon-reload
systemctl enable shellscript.service
```
 
# Run the custom SystemD service as a Corosync/Pacemaker Resource Agent

**Make sure the services are installed on every node of the cluster!**

1. Check that the RA is in the list of the resource agents under the systemd provider (it shoulud appear also as generic linux service)

```
pcs resource list
```

2. Create the resource. Also some operations on the resource are created. These operations allow to monitor, start and stop of the resource.

```
pcs resource create shellscript_resource systemd:shellscript \
op monitor interval=30s \
op start timeout=180s \
op stop timeout=180s \
op status timeout=15

```
*interval*: set the frequency for the operation

*timeout*: if the operation does not comlete by the amount set, abort the operation and consider it failed


# Extra

## Resouces
For LSB services:
* https://refspecs.linuxbase.org/LSB_3.0.0/LSB-PDA/LSB-PDA/iniscrptact.html

In case you want to create an OCF Resource Agent:
* https://serverfault.com/questions/964396/cluster-a-custom-application
* https://github.com/ClusterLabs/resource-agents/blob/00ae6a179d95471bd7ce37197b97bd9498c539a1/heartbeat/anything
