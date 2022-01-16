#
# Dockerfile for shadowsocks-libev
#

FROM alpine AS builder

RUN set -ex \
 # Build environment setup
 && apk update \
 && apk add --no-cache --virtual .build-deps \
      autoconf \
      automake \
      build-base \
      c-ares-dev \
      libev-dev \
      libtool \
      libsodium-dev \
      linux-headers \
      mbedtls-dev \
      pcre-dev \
      git \
      go \
 # Build & install
 && git clone https://github.com/shadowsocks/shadowsocks-libev.git /tmp/repo/shadowsocks-libev \
 && cd /tmp/repo/shadowsocks-libev \
 && git submodule update --init --recursive \
 && git rev-parse HEAD \
 && ./autogen.sh \
 && ./configure --prefix=/usr --disable-documentation \
 && make install \
 && ls -lh /usr/bin/ss-* \
 && ss-server -h

# ------------------------------------------------

FROM alpine

COPY --from=builder /usr/bin/ss-* /usr/bin/

RUN set -ex \
 && apk add --no-cache \
      rng-tools \
      $(scanelf --needed --nobanner /usr/bin/ss-* \
      | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
      | sort -u) \
 && ls -lh /usr/bin/ss-* \
 && ss-server -h
