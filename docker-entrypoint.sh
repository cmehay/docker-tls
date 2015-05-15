#!/bin/bash

set -e

gen_serv_tls () {
    # exit if cert file exist without key
    if [ -e "${SERVER_CRT}" ]; then
       echo >&2 "You provided certificate without key, exiting..."
       exit 1
    fi

    # Generate private and cert file
    openssl genrsa -out "${SERVER_KEY}" 2048 > /dev/null || exit 1
    openssl req -new -key "${SERVER_KEY}" -x509 -out "${SERVER_CRT}" -days 36525 -subj /CN=DOCKER/ || exit 1
}

gen_client_tls () {
    # Generate private and cert file

    if [ ! -e "${CLIENT_KEY}" ]; then
        openssl genrsa -out "${CLIENT_KEY}" 2048 > /dev/null || exit 1
    fi
    openssl req -new -key "${CLIENT_KEY}" -x509 -out "${CLIENT_CRT}" -days 36525 -subj /CN=DOCKER/ || exit 1
}

if [ "${1:0:1}" = '-' ] || [ -z "$1" ]; then
    set -- socat $@ \
        "OPENSSL-LISTEN:2376,fork,reuseaddr,cert=${SERVER_CRT},cafile=${CLIENT_CRT},key=${SERVER_KEY}" \
        "UNIX:${DOCKER_SOCK}"
fi

display_priv_key () {
    echo "Server private key (${SERVER_KEY})"
    cat "${SERVER_KEY}"
    echo
}

display_keys () {
    echo "Server certificate (${SERVER_CRT})"
    cat "${SERVER_CRT}"
    echo
    echo "Client private key (${CLIENT_KEY}):"
    if [ -e "${CLIENT_KEY}" ]; then
        cat "${CLIENT_KEY}"
    else
        echo "You provided your own client cert, no private key has been generated"
    fi
    echo
    echo "Client certificate (${CLIENT_CRT})"
    cat "${CLIENT_CRT}"
    echo

    echo
    echo "After copying these keys on your client, you can set your docker-cli using these options:"
    echo "	docker --host=\"host_ip:2376\" --tls --tlscacert=\"${SERVER_CRT}\" --tlscert=\"${CLIENT_CRT}\" --tlskey=\"${CLIENT_KEY}\""
    echo
    echo "You can also set environment variables and copy keys in ~/.docker directory:"
    echo "	export DOCKER_HOST=tcp://host_ip:2376 DOCKER_TLS=1"
    echo
    echo "This container provides getkeys cmd to retrieve all TLS keys, use docker exec on this running container to get them"
    echo "Enjoy :)"
}

if [ "$1" == "socat" ]; then

    echo debug 1
    # quit if docker sock is not here
    if [ ! -S "${DOCKER_SOCK}" ]; then
        echo >&2 "error: ${DOCKER_SOCK}: bad sock file"
        exit 1
    fi

    # gen TLS server key if not provided
    if [ ! -e "${SERVER_CRT}" ] || [ ! -e "${SERVER_KEY}" ]; then
        gen_serv_tls
    fi

    # gen TLS client key if not provided
    if [ ! -e "${CLIENT_CRT}" ]; then
        gen_client_tls
    fi

    # Display key and informations
    display_keys
fi

if [ "$1" == "getkeys" ]; then
    if [ $$ == "1" ]; then
        echo >&2 "This command needs this container to be running already, exiting..."
        exit 1
    fi
    display_priv_key
    display_keys
    exit 0
fi

echo exec "$@"

exec "$@"
