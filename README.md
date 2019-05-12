[![](https://img.shields.io/docker/pulls/alexanderkrause/rpi-nginx-proxy.svg)](https://hub.docker.com/r/alexanderkrause/rpi-nginx-proxy "Click to view the image on Docker Hub")

This is a [**fork**](https://github.com/Alexander-Krause/rpi-docker-nginx-proxy), that enables usage on a armhf architecture (tested on RPI 3). Have a look at Jason Wilder's [original](https://github.com/jwilder/nginx-proxy) repository and README. The following part does not include all available options of the original project.

### Why do you want to use this?
Reasons and examples for using a reverse proxy are discussed [by Jason Wilder](https://stackoverflow.com/a/366212/3250397) or [here](https://stackoverflow.com/a/366212/3250397).
With a [companion container](https://github.com/Alexander-Krause/rpi-docker-letsencrypt-nginx-proxy-companion) for creating/renewing *Let's Encrypt certificates* automatically you can use it with a Raspberry Pi and DynDNS Provider to host and expose your dockerized (and now TLS-secured) applications. Examples:

* [Nextcloud](https://github.com/nextcloud/docker) with [Passman](https://github.com/nextcloud/passman) extension and [MySQL](https://github.com/hypriot/rpi-mysql) (*tested*)
* [Nginx](https://github.com/armhf-docker-library/nginx) hosting your web sites (*tested*)
* Own Mailserver, e.g. [tomav/docker-mailserver](https://github.com/tomav/docker-mailserver), [hardware/mailserver](https://github.com/hardware/mailserver) or [Poste.io](https://poste.io/) (*not tested*)

### Usage
Built image is hosted on [Dockerhub](https://hub.docker.com/r/alexanderkrause/rpi-nginx-proxy). You can use 

    $ docker run -d -p 80:80 -v /var/run/docker.sock:/tmp/docker.sock:ro alexanderkrause/rpi-nginx-proxy:alpine`

to start a container, **but** SSL support (see below) is recommended.
 
### Self-Build

1. Clone this repository `$ git clone https://github.com/Alexander-Krause/rpi-nginx-proxy.git`
2. `$ cd rpi-nginx-proxy`
3. `$ docker build -t alexanderkrause/rpi-nginx-proxy:latest .`
4. `$ docker run -d -p 80:80 -v /var/run/docker.sock:/tmp/docker.sock:ro alexanderkrause/rpi-nginx-proxy`

Then start any containers you want proxied with an env var `VIRTUAL_HOST=subdomain.youdomain.com`

    $ docker run -e VIRTUAL_HOST=foo.bar.com  ...

### SSL Support using letsencrypt (recommend)

[rpi-docker-letsencrypt-nginx-proxy-companion](https://github.com/Alexander-Krause/rpi-docker-letsencrypt-nginx-proxy-companion) is a lightweight companion container for the nginx-proxy. It allows the creation/renewal of Let's Encrypt certificates automatically. 

### SSL Support

SSL is supported using single host, wildcard and SNI certificates using naming conventions for
certificates or optionally specifying a cert name (for SNI) as an environment variable.

To enable SSL:

    $ docker run -d -p 80:80 -p 443:443 -v /path/to/certs:/etc/nginx/certs -v /var/run/docker.sock:/tmp/docker.sock:ro alexanderkrause/rpi-nginx-proxy:alpine

The contents of `/path/to/certs` should contain the certificates and private keys for any virtual
hosts in use.  The certificate and keys should be named after the virtual host with a `.crt` and
`.key` extension.  For example, a container with `VIRTUAL_HOST=foo.bar.com` should have a
`foo.bar.com.crt` and `foo.bar.com.key` file in the certs directory.

### DynDNS

You can use for example https://www.duckdns.org to expose your Nextcloud container or something else. See [here](https://github.com/Alexander-Krause/rpi-docker-letsencrypt-nginx-proxy-companion/blob/master/README.md#dyndns) for more details.



