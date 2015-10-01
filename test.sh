#!/bin/bash
set -e

echo ""
echo ""
echo "-- Building Redis 3.0 image"
docker build -t redis-3.0 ./3.0

echo ""
echo "-- Testing Redis 3.0 is running"

docker run --name base_1 -d -e 'REDIS_PASSWORD=pass' redis-3.0; sleep 5
docker run --name base_2 -d --link base_1:base_1 redis-3.0; sleep 5
docker exec -it base_2 bash -c "echo 'ping' | redis-cli -c | grep -c 'PONG'"
docker exec -it base_2 bash -c "echo 'ping' | redis-cli -h base_1 -p 6379 -a pass -c | grep -c 'PONG'"
docker exec -it base_2 bash -c "echo 'ping' | redis-cli -h base_1 -p 6379 -c | grep -c 'NOAUTH'"
docker exec -it base_2 bash -c "echo 'SET foo bar' | redis-cli -h base_1 -p 6379 -a pass -c | grep -c 'OK'"
docker exec -it base_2 bash -c "echo 'GET foo' | redis-cli -h base_1 -p 6379 -a pass -c | grep -c 'bar'"
docker exec -it base_2 bash -c "echo 'ping' | redis-cli -h none -p 6379 -a pass -c" | grep -c 'service not known'

echo ""
echo "-- Clear"
docker rm -f -v $(sudo docker ps -aq); sleep 5

echo ""
echo "-- Testing Cluster Redis 3.0"
echo ""
echo "--- Create node1"
docker run --name node1 -d -e 'REDIS_CLUSTER_ENABLED=true' redis-3.0 --appendonly yes; sleep 5
echo ""
echo "--- Create node2"
docker run --name node2 -d -e 'REDIS_CLUSTER_ENABLED=true' redis-3.0 --appendonly yes; sleep 5
echo ""
echo "--- Create node3"
docker run --name node3 -d -e 'REDIS_CLUSTER_ENABLED=true' redis-3.0 --appendonly yes; sleep 5
echo ""
echo "--- Create node4"
docker run --name node4 -d -e 'REDIS_CLUSTER_ENABLED=true' redis-3.0 --appendonly yes; sleep 5
echo ""
echo "--- Create node5"
docker run --name node5 -d -e 'REDIS_CLUSTER_ENABLED=true' redis-3.0 --appendonly yes; sleep 5
echo ""
echo "--- Create node6 with links"
docker run --name node6 -d --link node1:node1 --link node2:node2 --link node3:node3 --link node4:node4 --link node5:node5 -e 'REDIS_CLUSTER_ENABLED=true' redis-3.0 --appendonly yes; sleep 5

echo ""
echo "--- Create cluster"
docker exec -it node6 bash -c 'echo "yes" | ruby /redis-trib.rb create --replicas 1 $(ifconfig | grep "inet addr:17" | cut -f2 -d ":" | cut -f1 -d " "):6379 node1:6379 node2:6379 node3:6379 node3:6379 node4:6379 node5:6379'; sleep 10
echo ""
echo "--- Testing cluster"
docker exec -it node6 bash -c "echo 'SET bar baz' | redis-cli -c | grep -c 'OK'"
docker exec -it node6 bash -c "echo 'GET bar' | redis-cli -c | grep -c 'baz'"


echo ""
echo "-- Clear"
docker rm -f -v $(sudo docker ps -aq); sleep 5
docker rmi -f redis-3.0


echo ""
echo ""
echo "-- Building Redis 2.8 image"
docker build -t redis-2.8 ./2.8

echo ""
echo "-- Testing Redis 2.8 is running"

docker run --name base_1 -d -e 'REDIS_PASSWORD=pass' redis-2.8; sleep 5
docker run --name base_2 -d --link base_1:base_1 redis-2.8; sleep 5
docker exec -it base_2 bash -c "echo 'ping' | redis-cli -c | grep -c 'PONG'"
docker exec -it base_2 bash -c "echo 'ping' | redis-cli -h base_1 -p 6379 -a pass -c | grep -c 'PONG'"
docker exec -it base_2 bash -c "echo 'ping' | redis-cli -h base_1 -p 6379 -c | grep -c 'NOAUTH'"
docker exec -it base_2 bash -c "echo 'SET foo bar' | redis-cli -h base_1 -p 6379 -a pass -c | grep -c 'OK'"
docker exec -it base_2 bash -c "echo 'GET foo' | redis-cli -h base_1 -p 6379 -a pass -c | grep -c 'bar'"
docker exec -it base_2 bash -c "echo 'ping' | redis-cli -h none -p 6379 -a pass -c" | grep -c 'service not known'
echo ""
echo "-- Clear"
docker rm -f -v $(sudo docker ps -aq); sleep 5
docker rmi -f redis-2.8

echo ""
echo "-- Done"