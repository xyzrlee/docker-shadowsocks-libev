#
# Dockerfile for shadowsocks-libev
#

FROM alpine
LABEL maintainer="Ricky Li <cnrickylee@gmail.com>"

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
 && git clone https://github.com/shadowsocks/v2ray-plugin.git /tmp/repo/v2ray-plugin \
 && cd /tmp/repo/shadowsocks-libev \
 && git submodule update --init --recursive \
 && git rev-parse HEAD \
 && ./autogen.sh \
 && ./configure --prefix=/usr --disable-documentation \
 && make install \
 && cd /tmp/repo/v2ray-plugin \
 && go build \
 && install v2ray-plugin /usr/bin \
 && cd / \
 && rm -rf /tmp/repo \
 && rm -rf $(go env GOCACHE) \
 && rm -rf $(go env GOPATH) \
 && apk del .build-deps \
 # Runtime dependencies setup
 && apk add --no-cache \
      rng-tools \
      $(scanelf --needed --nobanner /usr/bin/ss-* /usr/bin/v2ray-plugin \
      | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
      | sort -u) \
 && ls -lh /usr/bin/ss-* /usr/bin/v2ray-plugin \
 && ss-server -h \
 && v2ray-plugin -version

