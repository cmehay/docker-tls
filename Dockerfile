FROM debian:jessie

MAINTAINER Christophe Mehay

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 2376

# This container allow you to access docker server remotly through TLS

VOLUME /var/run/
VOLUME /etc/ssl/docker/

ENV    DOCKER_SOCK /var/run/docker.sock

ENV    SERVER_CRT /etc/ssl/docker/server.crt
ENV    SERVER_KEY /etc/ssl/docker/server.key
ENV    CLIENT_CRT /etc/ssl/docker/client.crt
ENV    CLIENT_KEY /etc/ssl/docker/client.key

RUN    apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install socat openssl

ADD    docker-entrypoint.sh /docker-entrypoint.sh
RUN    chmod +x /docker-entrypoint.sh

ADD    usr /usr
