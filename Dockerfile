FROM alpine AS go-builder

# Install build dependencies for docker-gen
RUN apk add --update \
        curl \
        gcc \
        git \
        make \
        musl-dev \
        go

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

# Build docker-gen
RUN go get github.com/jwilder/docker-gen \
    && cd /go/src/github.com/jwilder/docker-gen \
    && make get-deps \
    && make all

FROM nginx:alpine
LABEL maintainer="John Merchant <john@jmercha.dev>"

# Install wget and install/updates certificates
RUN apk add bash openssl ca-certificates wget

# Configure Nginx and apply fix for very long server names
RUN echo "daemon off;" >> /etc/nginx/nginx.conf \
 && sed -i 's/worker_processes  1/worker_processes  auto/' /etc/nginx/nginx.conf

# Install Docker Gen
COPY --from=go-builder /go/src/github.com/jwilder/docker-gen/docker-gen /usr/local/bin/

COPY network_internal.conf /etc/nginx/

COPY . /app/
WORKDIR /app/

ADD https://github.com/chrismytton/shoreman/raw/master/shoreman.sh /usr/bin/shoreman
RUN chmod 755 /usr/bin/shoreman

ENV DOCKER_HOST unix:///tmp/docker.sock

VOLUME ["/etc/nginx/certs", "/etc/nginx/dhparam"]

ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["shoreman"]


