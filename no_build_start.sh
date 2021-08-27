#!/bin/bash
#docker system prune --force
#docker volume prune --force
docker-compose up --build &
sleep 15
docker exec -ti service_01 /home/run.sh
sleep 5
corosync-cmapctl | grep members