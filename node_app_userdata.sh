#!/bin/bash
yum install docker -y

systemctl start docker.service
systemctl enable docker.service
usermod -a -G docker ec2-user

docker pull akhilanilkumar10/node-app:latest
docker container run --name nodejs_container1  -p 8080:8080 akhilanilkumar10/node-app:latest