FROM ubuntu:trusty
MAINTAINER romeOz <serggalka@gmail.com>


ENV REDIS_DOWNLOAD_URL=http://download.redis.io/releases/redis-3.0.4.tar.gz \
    REDIS_USER=redis \
    REDIS_CONF=/etc/redis/redis.conf \
    REDIS_DATA_DIR=/var/lib/redis \
    REDIS_LOG_DIR=/var/log/redis

COPY ./redis.conf ${REDIS_CONF}
COPY ./entrypoint.sh /sbin/entrypoint.sh

RUN buildDeps='gcc libc6-dev make curl' \
	&& set -x \
	&& apt-get update && apt-get install -y $buildDeps ruby --no-install-recommends \
	&& mkdir -p /tmp/redis \
	&& curl -sSL "$REDIS_DOWNLOAD_URL" -o redis.tar.gz \
	&& tar -xzf redis.tar.gz -C /tmp/redis --strip-components=1 \
	&& rm redis.tar.gz \
	&& make -C /tmp/redis \
	&& make -C /tmp/redis install \
	&& cp /tmp/redis/src/redis-trib.rb /redis-trib.rb \
	&& rm -rf /tmp/redi* \
	&& gem install redis \
	&& apt-get purge -y --auto-remove $buildDeps \
	&& rm -rf /var/lib/apt/lists/* \
	&& chmod 755 /sbin/entrypoint.sh

EXPOSE 6379
VOLUME ["${REDIS_DATA_DIR}"]
ENTRYPOINT ["/sbin/entrypoint.sh"]