#!/bin/bash
yum install docker -y

systemctl start docker.service
systemctl enable docker.service
usermod -a -G docker ec2-user

docker pull akhilanilkumar10/db-image:latest
docker volume create nodejs-mysqlvol
docker container run --name mysql_container -v nodejs-mysqlvol:/var/lib/mysql/ --network host akhilanilkumar10/db-image