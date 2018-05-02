FROM ubuntu:trusty
MAINTAINER romeOz <serggalka@gmail.com>


ENV REDIS_DOWNLOAD_URL=http://download.redis.io/releases/redis-2.8.24.tar.gz \
    REDIS_USER=redis \
    REDIS_CONF=/etc/redis/redis.conf \
    REDIS_DATA_DIR=/var/lib/redis \
    REDIS_LOG_DIR=/var/log/redis

COPY ./redis.conf ${REDIS_CONF}
COPY ./entrypoint.sh /sbin/entrypoint.sh

RUN BUILD_DEPS='gcc libc6-dev make curl' \
	&& set -x \
	&& apt-get update && apt-get install -y ${BUILD_DEPS} --no-install-recommends \
	&& mkdir -p /tmp/redis \
	&& curl -sSL "${REDIS_DOWNLOAD_URL}" -o redis.tar.gz \
	&& tar -xzf redis.tar.gz -C /tmp/redis --strip-components=1 \
	&& rm redis.tar.gz \
	&& make -C /tmp/redis \
	&& make -C /tmp/redis install \
	&& rm -rf /tmp/redi* \
	&& apt-get purge -y --auto-remove ${BUILD_DEPS} \
	&& rm -rf /var/lib/apt/lists/* \
	&& chmod 755 /sbin/entrypoint.sh

EXPOSE 6379
VOLUME ["${REDIS_DATA_DIR}"]
ENTRYPOINT ["/sbin/entrypoint.sh"]