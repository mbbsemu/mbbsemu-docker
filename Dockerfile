# Based on the LinuxServer.io DuckDNS image https://github.com/linuxserver/docker-duckdns

# Using Ubuntu instead of Alpine, since MBBSEmu is not Alpine compatible.
FROM lsiobase/ubuntu:bionic

ARG BUILD_DATE
ARG VERSION
LABEL build_version="MBBSEmu version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="fletcherm"

ENV CONFIG_PATH=/config
ENV EMULATOR_PATH=/app

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2

RUN \
 apt-get update && \
 apt-get install -qy --no-install-recommends \
	libicu60

COPY root/ /
COPY pkg/mbbsemu-linux-x64-*/MBBSEmu ${EMULATOR_PATH}

EXPOSE 2323
VOLUME ${CONFIG_PATH}
WORKDIR ${EMULATOR_PATH}
