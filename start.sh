#!/bin/bash
docker-compose up --build &
sleep 10
docker exec -ti node_01 /home/run.sh
sleep 5
docker exec -ti node_01 corosync-cmapctl | grep members
docker exec -ti node_01 pcs status
