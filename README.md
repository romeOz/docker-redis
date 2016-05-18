Table of Contents
-------------------

 * [Installation](#installation)
 * [Quick Start](#quick-start)
 * [Command-line arguments](#command-line-arguments)
 * [Setting a specific password](#setting-a-specific-password) 
 * [Persistence](#persistence)
 * [Creating cluster **(requires Redis 3.0+)**](#creating-cluster-requires-redis-30)
 * [Environment variables](#environment-variables) 
 * [Logging](#logging) 
 * [Out of the box](#out-of-the-box)

Installation
-------------------

 * [Install Docker 1.9+](https://docs.docker.com/installation/) or [askubuntu](http://askubuntu.com/a/473720)
 * Pull the latest version of the image.
 
```bash
docker pull romeoz/docker-redis
```

Alternately you can build the image yourself.

```bash
git clone https://github.com/romeoz/docker-redis.git
cd docker-redis
docker build -t="$USER/redis" .
```

Quick Start
-------------------

Run the redis container:

```bash
docker run --name redis -d \
  -p 6379:6379 \
  romeoz/docker-redis
```

Command-line arguments
-------------------

You can customize the launch command of Redis server by specifying arguments to `redis` on the docker run command. For example the following command for persistent storage:

```bash
docker run --name redis -d \
  -p 6379:6379 \
  romeoz/docker-redis --appendonly yes
```

Setting a specific password
-------------------

To secure your Redis server with a password, specify the password in the `REDIS_PASSWORD` variable while starting the container.

```bash
docker run --name redis -d \
  -p 6379:6379 \
  -e 'REDIS_PASSWORD=pass' \
  romeoz/docker-redis
```

Persistence
-------------------

For Redis to preserve its state across container shutdown and startup you should mount a volume at `/var/lib/redis`.

```bash
docker run --name redis -d \
  -p 6379:6379 \
  -v /host/to/path/data:/var/lib/redis
  romeoz/docker-redis --appendonly yes
```

Creating cluster **(requires Redis 3.0+)**
---------------------

Redis Cluster provides a way to run a Redis installation where data is automatically sharded across multiple Redis nodes.

Create nodes:

```bash
docker network create redis_net

docker run --name node1 -d \
  --net redis_net
  -e 'REDIS_CLUSTER_ENABLED=true' \
  romeoz/docker-redis --appendonly yes
```

Next, similarly to nodes 2..5.

>Note that the minimal cluster that works as expected requires to contain at least three master nodes. For your first tests it is strongly suggested to start a six nodes cluster with three masters and three slaves.

Use the 6-node as a provider:

```bash
docker run --name node6 -d \
  --net redis_net
  -e 'REDIS_CLUSTER_ENABLED=true' \
  romeoz/docker-redis --appendonly yes
```

Now that we have a number of instances running, we need to create our cluster by writing some meaningful configuration to the nodes. For this we use the utility `redis-trib`:

```bash
docker exec -it node6 bash -c '
IP=$(ifconfig | grep "inet addr:17" | cut -f2 -d ":" | cut -f1 -d " ") \

echo "yes" | \
ruby /redis-trib.rb create --replicas 1 ${IP}:6379 node1:6379 node2:6379 node3:6379 node3:6379 node4:6379 node5:6379'  
```

List of added nodes can be viewed with query `cluster nodes`:

```bash
docker exec -it node6 redis-cli cluster node
```

For more information you can refer to the [official documentation](http://redis.io/topics/cluster-tutorial).

Environment variables
---------------------

`REDIS_PASSWORD`: Set a specific password for the admin account.

`REDIS_CLUSTER_ENABLED`: Run Redis server as cluster (default "false").

`REDIS_CLUSTER_NODE_TIMEOUT`: The maximum amount of time a Redis Cluster node can be unavailable, without it being considered as failing. 
If a master node is not reachable for more than the specified amount of time, it will be failed over by its slaves (default "5000").

Logging
-------------------

All the logs are forwarded to stdout and sterr. You have use the command `docker logs`.

```bash
docker logs redis
```

####Split the logs

You can then simply split the stdout & stderr of the container by piping the separate streams and send them to files:

```bash
docker logs redis > stdout.log 2>stderr.log
cat stdout.log
cat stderr.log
```

or split stdout and error to host stdout:

```bash
docker logs redis > -
docker logs redis 2> -
```

####Rotate logs

Create the file `/etc/logrotate.d/docker-containers` with the following text inside:

```
/var/lib/docker/containers/*/*.log {
    rotate 31
    daily
    nocompress
    missingok
    notifempty
    copytruncate
}
```
> Optionally, you can replace `nocompress` to `compress` and change the number of days.


Out of the box
-------------------
 * Ubuntu 14.04 LTS
 * Redis 2.8 or 3.0

License
-------------------

Redis docker image is open-sourced software licensed under the [MIT license](http://opensource.org/licenses/MIT)