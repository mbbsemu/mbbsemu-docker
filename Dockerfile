# Based on the LinuxServer.io DuckDNS image https://github.com/linuxserver/docker-duckdns
# and other images, like the Unifi controller https://github.com/linuxserver/docker-unifi-controller/blob/master/Dockerfile

# Using Ubuntu instead of Alpine, since MBBSEmu is not Alpine compatible.
FROM lsiobase/ubuntu:bionic

ARG BUILD_DATE
ARG VERSION
LABEL build_version="MBBSEmu version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="fletcherm"

# Gets rid of an obnoxious, red, scary looking non-error during build.
# https://askubuntu.com/questions/344962/how-do-i-correct-this-error-with-debootstrap-in-ubuntu-server-12-04-3
ARG DEBIAN_FRONTEND=noninteractive

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2
ENV DOTNET_BUNDLE_EXTRACT_BASE_DIR=/tmp

ENV CONFIG_PATH=/config
ENV EMULATOR_PATH=/app

RUN \
 apt-get update && \
 apt-get install -qy --no-install-recommends \
	libicu60

COPY root/ /
COPY pkg/mbbsemu-linux-x64-${VERSION}/MBBSEmu ${EMULATOR_PATH}

RUN chmod a+x ${EMULATOR_PATH}/MBBSEmu

VOLUME ${CONFIG_PATH}
WORKDIR ${CONFIG_PATH}
