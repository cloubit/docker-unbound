# Dockerfile for Unbound DNS Resolver Docker Image

[Unbound](https://www.nlnetlabs.nl/projects/unbound/about/) is an open source, stable, validating, recursive, and caching DNS resolver, developed by [NLnet Labs](https://www.nlnetlabs.nl/)

## Image details

-  NSD 1.23.0
-  Openssl 3.5.0

## Create Docker image
If you have Git installed, clone the Unbound repository to your localhost with
```sh
git clone https://github.com/cloubit/docker-unbound.git
```
or download the last repository.

If you have docker installed, you can create your own Docker Image about:
```sh
docker build -t unbound:1.23.0 .
```

## Run the UNBOUND Docker Container
If you have make no change about the unbound.conf, the running config file ist inside your image.
Now you can start the Unbound Docker image about:
```sh
docker run --name unbound -d -p 53:53/udp -p 53:53/tcp \
--restart=always unbound:1.23.0
```

If you have your own Unbound config file, for example you have running the NSD-DNS-Server and you use STUB-Zones, then copy your costomized unbound.conf in the linked folder and
start the Docker container with following command:
```sh 
docker run --name unbound -d -p 53:53/udp -p 53:53/tcp --volume </local/path/to/your/config:/opt/unbound/etc/unbound \
--restart=always unbound:1.23.0
```

## Docker Hub
[Link to the Unbound Docker image](https://hub.docker.com/r/cloubit/unbound)
