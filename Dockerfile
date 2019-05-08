FROM alpine:3.9 as builder
WORKDIR /tmp/
RUN sed -i -e 's/v[[:digit:]]\.[[:digit:]]/edge/g' /etc/apk/repositories && \
    apk upgrade --update-cache --available && \
    apk add --no-cache \
	  alpine-sdk \
	  linux-headers \
	  make \
	  automake \
	  autoconf \
	  fuse3-dev \
	  go-md2man \
	  ca-certificates \
	  wget && \
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.29-r0/glibc-2.29-r0.apk && \
    apk add glibc-2.29-r0.apk && \
    git clone https://github.com/containers/fuse-overlayfs && \
    cd fuse-overlayfs && \
    sh autogen.sh && \
    LIBS="-ldl" LDFLAGS="-static" ./configure --prefix /usr && \
    ./configure && \
    make && \
    make install

FROM alpine:3.9  
# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="Docker OverlayFS Mount" \
      org.label-schema.description="OverlayFS Mmount based on alpine/s6-overlay" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/meyayl/docker-overlayfs-mount" \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0"

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2 TZ="Europe/Berlin" PUID=1000 PGID=1000 LOWER_DIR=/lower UPPER_DIR=/upper WORK_DIR=/work MERGED_DIR=/merged
COPY --from=builder /tmp/fuse-overlayfs/fuse-overlayfs /tmp/fuse-overlayfs 

RUN \
  echo "**** install s6-overlay ****" && \
  apk add --no-cache curl && \
  curl -L -s https://github.com/just-containers/s6-overlay/releases/download/v1.21.8.0/s6-overlay-amd64.tar.gz | tar xvzf - -C / && \
  echo "**** install runtime packages ****" && \
  sed -i -e 's/v[[:digit:]]\.[[:digit:]]/edge/g' /etc/apk/repositories && \
  apk upgrade --update-cache --available && \
  apk add --no-cache \
    tzdata \
    fuse3 && \
  echo "**** configure fuse3 ****" && \
  sed -ri 's/^#user_allow_other/user_allow_other/' /etc/fuse.conf && \
  echo "**** install fuse-overlayfs ****" && \
  /usr/bin/install -c /tmp/fuse-overlayfs '/usr/local/bin' && \
  echo "**** cleanup ****" && \
  apk del --no-cache \
    curl \
	wget && \
  rm -rf /tmp/*

COPY root/ /
VOLUME ["/upper", "/lower", "/work", "/merged"]
CMD ["/init"]
