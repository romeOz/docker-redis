#!/bin/bash

set -e

echo "-- Building Redis 2.8 image"
docker build -t redis-2.8 ../2.8/
docker network create redis_test_net

echo
echo "-- Testing Redis 2.8 is running"

docker run --name base_1 -d --net redis_test_net -e 'REDIS_PASSWORD=pass' redis-2.8; sleep 5
docker run --name base_2 -d --net redis_test_net redis-2.8; sleep 5
docker exec -it base_2 bash -c "echo 'ping' | redis-cli -c | grep -c 'PONG'"
docker exec -it base_2 bash -c "echo 'ping' | redis-cli -h base_1 -p 6379 -a pass -c | grep -c 'PONG'"
docker exec -it base_2 bash -c "echo 'ping' | redis-cli -h base_1 -p 6379 -c | grep -c 'NOAUTH'"
docker exec -it base_2 bash -c "echo 'SET foo bar' | redis-cli -h base_1 -p 6379 -a pass -c | grep -c 'OK'"
docker exec -it base_2 bash -c "echo 'GET foo' | redis-cli -h base_1 -p 6379 -a pass -c | grep -c 'bar'"
docker exec -it base_2 bash -c "echo 'ping' | redis-cli -h none -p 6379 -a pass -c" | grep -c 'service not known'
echo
echo "-- Clear"
docker rm -f -v base_1 base_2; sleep 5
docker network rm redis_test_net
docker rmi -f redis-2.8


echo
echo "-- Done"