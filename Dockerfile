FROM golang:1.11-alpine AS go-builder

# Install build dependencies for docker-gen and forego
RUN apk add --update \
        curl \
        gcc \
        git \
        make \
        musl-dev

# Build docker-gen
RUN go get github.com/jwilder/docker-gen \
    && cd /go/src/github.com/jwilder/docker-gen \
    && make get-deps \
    && make all

# Build forego
RUN go get github.com/ddollar/forego \
    && cd /go/src/github.com/ddollar/forego \
    && make all

FROM nginx
LABEL maintainer="John Merchant <john@jmercha.dev>"

# Install wget and install/updates certificates
RUN apt-get update \
 && apt-get install -y -q --no-install-recommends \
    ca-certificates \
    wget \
 && apt-get clean \
 && rm -r /var/lib/apt/lists/*


# Configure Nginx and apply fix for very long server names
RUN echo "daemon off;" >> /etc/nginx/nginx.conf \
 && sed -i 's/worker_processes  1/worker_processes  auto/' /etc/nginx/nginx.conf

# Install Docker Gen
COPY --from=go-builder /go/src/github.com/jwilder/docker-gen/docker-gen /usr/local/bin/

# Install Forego
COPY --from=go-builder /go/src/github.com/ddollar/forego/forego /usr/local/bin/

COPY network_internal.conf /etc/nginx/

COPY . /app/
WORKDIR /app/

ENV DOCKER_HOST unix:///tmp/docker.sock

VOLUME ["/etc/nginx/certs", "/etc/nginx/dhparam"]

ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["forego", "start", "-r"]


