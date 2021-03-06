#!/bin/bash
#
# Script to start docker and update the /etc/hosts file to point to
# the hbase-docker container
#
# hbase thrift and master server logs are written to the local
# logs directory
#

echo "Starting HBase container"
logs=$PWD/logs
rm -rf $logs
mkdir -p $logs
#id=$(docker run -d -v $logs:/opt/hbase/logs -p 2181:2181 -p 9000:9090 -p 16000:16000 -p 16010:16010 -p 16020:16020 -p 16030:16030 6pongi/hbase)
#id=$(docker run -d -p 2181:2181 -p 9000:9090 -p 16000:16000 -p 16010:16010 -p 16020:16020 -p 16030:16030 6pongi/hbase)
id=$(docker run -d -v /tmp/dev:/opt/hbase/logs -p 2181:2181 -p 9000:9090 -p 16000:16000 -p 16010:16010 -p 16020:16020 -p 16030:16030 6pongi/hbase)

echo "Container has ID $id"

# Get the hostname and IP inside the container
docker inspect $id > config.json
docker_hostname=`python -c 'import json; c=json.load(open("config.json")); print c[0]["Config"]["Hostname"]'`
docker_ip=`python -c 'import json; c=json.load(open("config.json")); print c[0]["NetworkSettings"]["IPAddress"]'`
rm -f config.json

echo "Updating /etc/hosts to make hbase-docker point to $docker_ip ($docker_hostname)"
if grep 'hbase-docker' /etc/hosts >/dev/null; then
  sudo sed -i "s/^.*hbase-docker.*\$/$docker_ip hbase-docker $docker_hostname/" /etc/hosts
else
  sudo sh -c "echo '$docker_ip hbase-docker $docker_hostname' >> /etc/hosts"
fi

echo "Now connect to hbase at localhost on the standard ports"
echo "  ZK 2181, Thrift 9090, Master 16000, Region 16020"
echo "Or connect to host hbase-docker (in the container) on the same ports"
echo ""
echo "For docker status:"
echo "$ id=$id"
echo "$ docker ps $$id"
