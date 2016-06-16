#!/bin/bash

set -e


echo "-- Building Redis 3.2 image"
docker build -t redis-3.2 ../3.2/
docker network create redis_test_net

echo
echo "-- Testing Redis 3.2 is running"

docker run --name base_1 -d --net redis_test_net -e 'REDIS_PASSWORD=pass' redis-3.2; sleep 5
docker run --name base_2 -d --net redis_test_net redis-3.2; sleep 5
docker exec -it base_2 bash -c "echo 'ping' | redis-cli -c | grep -c 'PONG'"
docker exec -it base_2 bash -c "echo 'ping' | redis-cli -h base_1 -p 6379 -a pass -c | grep -c 'PONG'"
docker exec -it base_2 bash -c "echo 'ping' | redis-cli -h base_1 -p 6379 -c | grep -c 'NOAUTH'"
docker exec -it base_2 bash -c "echo 'SET foo bar' | redis-cli -h base_1 -p 6379 -a pass -c | grep -c 'OK'"
docker exec -it base_2 bash -c "echo 'GET foo' | redis-cli -h base_1 -p 6379 -a pass -c | grep -c 'bar'"
docker exec -it base_2 bash -c "echo 'ping' | redis-cli -h none -p 6379 -a pass -c" | grep -c 'service not known'

echo
echo "-- Clear"
docker rm -f -v base_1 base_2; sleep 5

echo
echo "-- Testing Cluster Redis 3.2"
echo

echo "-- Create node1"
docker run --name node1 -d --net redis_test_net -e 'REDIS_CLUSTER_ENABLED=true' redis-3.2 --appendonly yes; sleep 5
echo
echo "-- Create node2"
docker run --name node2 -d --net redis_test_net -e 'REDIS_CLUSTER_ENABLED=true' redis-3.2 --appendonly yes; sleep 5
echo
echo "-- Create node3"
docker run --name node3 -d --net redis_test_net -e 'REDIS_CLUSTER_ENABLED=true' redis-3.2 --appendonly yes; sleep 5
echo
echo "-- Create node4"
docker run --name node4 -d --net redis_test_net -e 'REDIS_CLUSTER_ENABLED=true' redis-3.2 --appendonly yes; sleep 5
echo
echo "-- Create node5"
docker run --name node5 -d --net redis_test_net -e 'REDIS_CLUSTER_ENABLED=true' redis-3.2 --appendonly yes; sleep 5
echo
echo "-- Create node6 as provider"
docker run --name node6 -d --net redis_test_net -e 'REDIS_CLUSTER_ENABLED=true' redis-3.2 --appendonly yes; sleep 5

echo
echo "-- Protected mode as 'no' for nodes"
docker exec -it node1 bash -c "echo 'CONFIG SET protected-mode no' | redis-cli -c"
docker exec -it node2 bash -c "echo 'CONFIG SET protected-mode no' | redis-cli -c"
docker exec -it node3 bash -c "echo 'CONFIG SET protected-mode no' | redis-cli -c"
docker exec -it node4 bash -c "echo 'CONFIG SET protected-mode no' | redis-cli -c"
docker exec -it node5 bash -c "echo 'CONFIG SET protected-mode no' | redis-cli -c"
docker exec -it node6 bash -c "echo 'CONFIG SET protected-mode no' | redis-cli -c"; sleep 5

echo
echo "-- Create cluster"
docker exec -it node6 bash -c 'echo "yes" | ruby /redis-trib.rb create --replicas 1 $(ifconfig | grep "inet addr:17" | cut -f2 -d ":" | cut -f1 -d " "):6379 node1:6379 node2:6379 node3:6379 node3:6379 node4:6379 node5:6379'; sleep 10
echo
echo "-- Testing cluster"
docker exec -it node6 bash -c "echo 'SET bar baz' | redis-cli -c | grep -c 'OK'"
docker exec -it node6 bash -c "echo 'GET bar' | redis-cli -c | grep -c 'baz'"



echo
echo "-- Clear"
docker rm -f -v node1 node2 node3 node4 node5 node6; sleep 5
docker network rm redis_test_net
docker rmi -f redis-3.2

echo
echo "-- Done"