# Based on the LinuxServer.io DuckDNS image https://github.com/linuxserver/docker-duckdns
# and other images, like the Unifi controller https://github.com/linuxserver/docker-unifi-controller/blob/master/Dockerfile
FROM lsiobase/ubuntu:jammy-a9a08161-ls80

ARG BUILD_DATE
ARG VERSION
LABEL build_version="MBBSEmu version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="fletcherm"

ENV CONFIG_PATH=/config
ENV DEBIAN_FRONTEND=noninteractive
ENV DOTNET_BUNDLE_EXTRACT_BASE_DIR=/tmp
ENV EMULATOR_PATH=/app

RUN apt-get update && \
    apt-get install -qy --no-install-recommends libicu70

COPY root/ /
COPY pkg/mbbsemu-linux-x64-${VERSION}/MBBSEmu ${EMULATOR_PATH}

RUN chmod a+x ${EMULATOR_PATH}/MBBSEmu

VOLUME ${CONFIG_PATH}
WORKDIR ${CONFIG_PATH}
