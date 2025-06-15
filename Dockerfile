# GLOBAL BUILD ARG
ARG UNBOUND_IMAGE_VERSION=1.23.0
ARG UNBOUND_IMAGE_REVISION=a

# UNBOUND BUILDER
FROM alpine:latest AS builder
LABEL maintainer="cloubit"

# install required programms and dependencies
RUN set -x -e; \
  apk --update --no-cache add \
    ca-certificates \
    curl \
    gnupg \
    shadow \
    linux-headers \
    perl \
    build-base \
    libsodium-dev \
    protobuf-c-dev \
  rm -rf /usr/share/man /usr/share/docs /tmp/* /var/tmp/* /var/log/*

# openssl install
ENV OPENSSL_VERSION=openssl-3.5.0 \
  OPENSSL_DOWNLOAD_URL=https://github.com/openssl/openssl/releases/download \
  OPENSSL_SHA256=344d0a79f1a9b08029b0744e2cc401a43f9c90acd1044d09a530b4885a8e9fc0 \
  OPENSSL_PGP_0=BA5473A2B0587B07FB27CF2D216094DFD0CB81EF

WORKDIR /tmp/openssl

RUN set -x -e; \
  curl -sSL "${OPENSSL_DOWNLOAD_URL}"/"${OPENSSL_VERSION}"/"${OPENSSL_VERSION}".tar.gz -o openssl.tar.gz && \
  echo "${OPENSSL_SHA256} ./openssl.tar.gz" | sha256sum -c - && \
  curl -sSL "${OPENSSL_DOWNLOAD_URL}"/"${OPENSSL_VERSION}"/"${OPENSSL_VERSION}".tar.gz.asc -o openssl.tar.gz.asc && \
  GNUPGHOME="$(mktemp -d)" && \
  export GNUPGHOME && \
  gpg --no-tty --keyserver hkps://keys.openpgp.org --recv-keys "${OPENSSL_PGP_0}" && \
  gpg --batch --verify openssl.tar.gz.asc openssl.tar.gz && \
  tar -xzf openssl.tar.gz && \
  rm -f openssl.tar.gz && \
  cd "${OPENSSL_VERSION}" && \
  ./Configure \
    --prefix=/usr/local \
    no-weak-ssl-ciphers \
    no-docs \
    no-ssl3 \
    no-err \
    no-autoerrinit \
    no-shared \
    enable-tfo \
    enable-ktls \
    enable-ec_nistp_64_gcc_128 \
    -fPIC \
    -DOPENSSL_NO_HEARTBEATS \
    -fstack-protector-strong \
    -fstack-clash-protection && \
  make && \
  make -j$(nproc) && \
  make install_sw &&\
  rm -rf /usr/share/man /usr/share/docs /tmp/* /var/tmp/* /var/log/*

# libevent install
ENV LIBEVENT_RELEASE=release-2.1.12-stable \
  LIBEVENT_VERSION=libevent-2.1.12-stable \
  LIBEVENT_DOWNLOAD_URL=https://github.com/libevent/libevent/releases/download \
  LIBEVENT_SHA256=92e6de1be9ec176428fd2367677e61ceffc2ee1cb119035037a27d346b0403bb

WORKDIR /tmp/libevent

RUN curl -sSL "${LIBEVENT_DOWNLOAD_URL}"/"${LIBEVENT_RELEASE}"/"${LIBEVENT_VERSION}".tar.gz -o libevent.tar.gz && \
  echo "${LIBEVENT_SHA256} ./libevent.tar.gz" | sha256sum -c - && \
  tar -xzf libevent.tar.gz && \
  rm -f libevent.tar.gz && \
  cd "${LIBEVENT_VERSION}" && \
	./configure \
    --libdir=/usr/local/lib \
    --includedir=/usr/local/include \
    --enable-openssl \
    --enable-static \
    --disable-shared && \
	make -j$(nproc) && \
	make install && \
  rm -rf /usr/share/man /usr/share/docs /tmp/* /var/tmp/* /var/log/*

# libexpat install
ENV LIBEXPAT_RELEASE=R_2_7_1 \
  LIBEXPAT_VERSION=expat-2.7.1 \
  LIBEXPAT_DOWNLOAD_URL=https://github.com/libexpat/libexpat/releases/download \
  LIBEXPAT_SHA256=0cce2e6e69b327fc607b8ff264f4b66bdf71ead55a87ffd5f3143f535f15cfa2 \
  LIBEXPAT_PGP_0=3176EF7DB2367F1FCA4F306B1F9B0E909AF37285

WORKDIR /tmp/libexpat

RUN curl -sSL "${LIBEXPAT_DOWNLOAD_URL}"/"${LIBEXPAT_RELEASE}"/"${LIBEXPAT_VERSION}".tar.gz -o libexpat.tar.gz && \
  echo "${LIBEXPAT_SHA256} ./libexpat.tar.gz" | sha256sum -c - && \
  curl -sSL "${LIBEXPAT_DOWNLOAD_URL}"/"${LIBEXPAT_RELEASE}"/"${LIBEXPAT_VERSION}".tar.gz.asc -o libexpad.tar.gz.asc && \
  GNUPGHOME="$(mktemp -d)" && \
  export GNUPGHOME && \
  gpg --no-tty --keyserver hkps://keys.openpgp.org --recv-keys "${LIBEXPAT_PGP_0}" && \
  gpg --batch --verify libexpad.tar.gz.asc libexpat.tar.gz && \
  tar -xzf libexpat.tar.gz && \
  rm -f libexpat.tar.gz && \
  cd "${LIBEXPAT_VERSION}" && \
  ./configure \
    --libdir=/usr/local/lib \
    --includedir=/usr/local/include \
    --enable-static \
    --disable-shared && \
  make -j$(nproc) && \
  make install && \
  rm -rf /usr/share/man /usr/share/docs /tmp/* /var/tmp/* /var/log/*

# nghttp2 install
ENV NGHTTP2_RELEASE=v1.65.0 \
  NGHTTP2_VERSION=nghttp2-1.65.0 \
  NGHTTP2_DOWNLOAD_URL=https://github.com/nghttp2/nghttp2/releases/download \
  NGHTTP2_SHA256=8ca4f2a77ba7aac20aca3e3517a2c96cfcf7c6b064ab7d4a0809e7e4e9eb9914 \
  NGHTTP2_PGP_0=516B622918D15C478AB1EA3A5339A2BE82E07DEC

WORKDIR /tmp/libnghttp2

RUN curl -sSL "${NGHTTP2_DOWNLOAD_URL}"/"${NGHTTP2_RELEASE}"/"${NGHTTP2_VERSION}".tar.gz -o nghttp2.tar.gz && \
  echo "${NGHTTP2_SHA256} ./nghttp2.tar.gz" | sha256sum -c - && \
  curl -sSL "${NGHTTP2_DOWNLOAD_URL}"/"${NGHTTP2_RELEASE}"/"${NGHTTP2_VERSION}".tar.gz.asc -o nghttp2.tar.gz.asc && \
  GNUPGHOME="$(mktemp -d)" && \
  export GNUPGHOME && \
  gpg --no-tty --keyserver hkps://keyserver.ubuntu.com --recv-keys "${NGHTTP2_PGP_0}" && \
  gpg --batch --verify nghttp2.tar.gz.asc nghttp2.tar.gz && \
  tar -xzf nghttp2.tar.gz && \
  rm -f nghttp2.tar.gz && \
  cd "${NGHTTP2_VERSION}" && \
  ./configure \
    --libdir=/usr/local/lib \
    --includedir=/usr/local/include \
    --enable-static \
    --disable-shared && \
  make -j$(nproc) && \
  make install && \
  rm -rf /usr/share/man /usr/share/docs /tmp/* /var/tmp/* /var/log/*

# ldns install
ENV LDNS_VERSION=ldns-1.8.4 \
  LDNS_DOWNLOAD_URL=https://nlnetlabs.nl/downloads/ldns \
  LDNS_SHA256=838b907594baaff1cd767e95466a7745998ae64bc74be038dccc62e2de2e4247 \
  LDNS_PGP_0=DC34EE5DB2417BCC151E5100E5F8F8212F77A498

WORKDIR /tmp/ldns

RUN set -x -e; \
    curl -sSL "${LDNS_DOWNLOAD_URL}"/"${LDNS_VERSION}".tar.gz -o ldns.tar.gz && \
    echo "${LDNS_SHA256} ./ldns.tar.gz" | sha256sum -c - && \
    curl -L "${LDNS_DOWNLOAD_URL}"/"${LDNS_VERSION}".tar.gz.asc -o ldns.tar.gz.asc && \
    GNUPGHOME="$(mktemp -d)" && \
    export GNUPGHOME && \
    gpg --no-tty --keyserver hkps://keys.openpgp.org --recv-keys "${LDNS_PGP_0}" && \
    gpg --batch --verify ldns.tar.gz.asc ldns.tar.gz && \
    tar -xzf ldns.tar.gz && \
    rm -f ldns.tar.gz && \
    cd "${LDNS_VERSION}" && \
    ./configure \
      --prefix=/usr/local \
      --with-ssl \
      --with-drill \
      --enable-static \
      --disable-shared &&\
    make -j$(nproc) &&\
    make install && \
    rm -rf /usr/share/man /usr/share/docs /tmp/* /var/tmp/* /var/log/*

# unbound install
ENV UNBOUND_VERSION=unbound-1.23.0 \
  UNBOUND_DOWNLOAD_URL=https://nlnetlabs.nl/downloads/unbound \
  # UNBOUND_SHA256=c5dd1bdef5d5685b2cedb749158dd152c52d44f65529a34ac15cd88d4b1b3d43 \
  UNBOUND_SHA256=959bd5f3875316d7b3f67ee237a56de5565f5b35fc9b5fc3cea6cfe735a03bb8 \
  UNBOUND_PGP_0=F0CB1A326BDF3F3EFA3A01FA937BB869E3A238C5 \
  UNBOUND_PGP_1=EDFAA3F2CA4E6EB05681AF8E9F6F1C2D7E045F8D

WORKDIR /tmp/unbound

RUN set -x -e; \
  curl -sSL "${UNBOUND_DOWNLOAD_URL}"/"${UNBOUND_VERSION}".tar.gz -o unbound.tar.gz && \
  echo "${UNBOUND_SHA256} ./unbound.tar.gz" | sha256sum -c - && \
  curl -sSL "${UNBOUND_DOWNLOAD_URL}"/"${UNBOUND_VERSION}".tar.gz.asc -o unbound.tar.gz.asc && \
  GNUPGHOME="$(mktemp -d)" && \
  export GNUPGHOME && \
  gpg --no-tty --keyserver hkps://keys.openpgp.org --recv-keys "${UNBOUND_PGP_0}" "${UNBOUND_PGP_1}" && \
  gpg --batch --verify unbound.tar.gz.asc unbound.tar.gz && \
  tar -xzf unbound.tar.gz && \
  rm -f unbound.tar.gz && \
  groupadd _unbound && \
  useradd -g _unbound -s /dev/null -d /dev/null _unbound && \
  cd "${UNBOUND_VERSION}" && \
  ./configure \
    --prefix=/opt/unbound \
    --with-username=_unbound \
    --with-ssl \
    --with-libevent=/usr/local \
    --with-libexpat=/usr/local \
    --with-libnghttp2=/usr/local \
    --with-pthreads \
    --without-pythonmodule \
    --without-pyunbound \
    --enable-dnstap \
    --enable-dnscrypt \
    --enable-cachedb \
    --enable-subnet \
    --enable-tfo-server \
    --enable-tfo-client \
    --enable-relro-now \
    --enable-event-api \
    --enable-static \
    --disable-shared && \
  make -j$(nproc) && \
  make install && \
  pkill -9 gpg-agent && \
  pkill -9 dirmngr && \
  mv /opt/unbound/etc/unbound/unbound.conf /opt/unbound/etc/unbound/example.conf && \
  rm -rf /usr/share/man /usr/share/docs /tmp/* /var/tmp/* /var/log/* /opt/unbound/include /opt/unbound/share && \
  mkdir -p /tmp/unbound/dev && \
  cp -a /dev/random /dev/urandom /dev/null /tmp/unbound/dev


# UNBOUND STAGE
FROM scratch AS stage
LABEL maintainer="cloubit"

# copy required programs and dependencies to stage
COPY --from=builder /opt/unbound/ \
  /stage/opt/unbound/
COPY --from=builder /bin/sh /bin/ls /bin/rm /bin/cp /bin/cat /bin/mkdir /bin/chown /bin/chmod \
 /stage/bin/
COPY --from=builder /usr/local/bin/ \
  /stage/usr/local/bin/
COPY --from=builder /lib/*musl* \
 /stage/lib/
COPY --from=builder /usr/lib/libproto* /usr/lib/libs* /usr/lib/libz* \
  /stage/usr/lib/
COPY --from=builder /usr/local/lib* /usr/local/lib/ossl-modules/ \
  /stage/usr/local/lib/
COPY --from=builder /etc/passwd /etc/shadow /etc/group \
  /stage/etc/
COPY --from=builder /etc/ssl/certs/ \
  /stage/etc/ssl/certs/
COPY --from=builder /tmp/unbound/dev \
  /stage/tmp/unbound/dev


# UNBOUND FINAL
FROM scratch

ARG UNBOUND_IMAGE_VERSION
ARG UNBOUND_IMAGE_REVISION
ENV UNBOUND_IMAGE=${UNBOUND_IMAGE_VERSION}-${UNBOUND_IMAGE_REVISION}
ARG UNBOUND_CONFIG=data
ENV UNBOUND_CONFIG=${UNBOUND_CONFIG}

LABEL maintainer="cloubit" \
  org.opencontainers.image.version=${UNBOUND_IMAGE} \
  org.opencontainers.image.title="Unbound on Docker" \
  org.opencontainers.image.description="Unbound is a validating, recursive, and caching DNS resolver." \
  org.opencontainers.image.summary="Distroless Unbound Docker image, based on Alpine Linux, with focus on security and privacy." \
  org.opencontainers.image.vendor="Cloubit GmbH" \
  org.opencontainers.image.base.name="cloubit/unbound" \
  org.opencontainers.image.url="https://hub.docker.com/repository/docker/cloubit/unbound" \
  org.opencontainers.image.source="https://github.com/cloubit/unbound-docker" \
  org.opencontainers.image.authors="cloubit" \
  org.opencontainers.image.licenses="MIT"

COPY --from=stage /stage /
COPY ${UNBOUND_CONFIG} /opt/unbound/etc/unbound/

RUN mkdir -p -m 700 /opt/unbound/etc/unbound/var && \
  mkdir -p -m 700 /opt/unbound/etc/unbound/dev && \
  chown -R _unbound /opt/unbound/etc/unbound && \
  cp -a /tmp/unbound/dev/random /tmp/unbound/dev/urandom  /tmp/unbound/dev/null  /opt/unbound/etc/unbound/dev && \
  rm -rf /tmp

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
  CMD drill -D -o cd @127.0.0.1 cloudflare.com

EXPOSE 53/tcp 53/udp

WORKDIR /opt/unbound/

ENV PATH=/opt/unbound/sbin:"$PATH"

ENTRYPOINT /opt/unbound/sbin/unbound-anchor -v -a /opt/unbound/etc/unbound/var/root.key || true && \
  unbound -d -c /opt/unbound/etc/unbound/unbound.conf
