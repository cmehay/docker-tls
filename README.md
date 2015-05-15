# docker-tls

Configuring TLS and x509 on docker server is boring.

docker-machine can be used for this purpose but it won't be very usefull on baremetal server.

This image allows you to access docker through TLS.

It builds TLS keys and provides a reverse socat proxy.

## Use

```
docker run -ti --name docker-tls -p 2376:2376 -v /var/run/:/var/run/ goldy/docker-tls
```

You can also retrieve keys on running container:
```
docker exec docker-tls getkeys
```

## Env var

You can provide your own TLS keys if you want
* *SERVER_CRT*: `/etc/ssl/docker/server.crt`
* *SERVER_KEY*: `/etc/ssl/docker/server.key`
* *CLIENT_CRT*: `/etc/ssl/docker/client.crt`

`/etc/ssl/docker/` is a volume.

You can also change the docker unix socket
* *DOCKER_SOCK*: `/var/run/docker.sock`
