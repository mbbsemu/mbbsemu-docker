# Based on the LinuxServer.io DuckDNS image https://github.com/linuxserver/docker-duckdns
# Using Ubuntu instead of Alpine, since MBBSEmu is not Alpine compatible.

FROM lsiobase/ubuntu:bionic

ARG BUILD_DATE
ARG VERSION
LABEL build_version="MBBSEmu version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="fletcherm"

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2

RUN \
 apt-get update && \
 apt-get install -y \
	libicu60

COPY root/ /
COPY pkg/mbbsemu-linux-x64-*/MBBSEmu /app

# ENV CONFIG_PATH /config
# ENV DATA_PATH /data
# ENV EMULATOR_PATH /mbbsemu
# ENV MODULES_PATH /modules

# COPY pkg/mbbsemu-linux-x64-* ${EMULATOR_PATH}
# COPY run.sh ${EMULATOR_PATH}
# COPY setup.sh ${EMULATOR_PATH}

# WORKDIR ${EMULATOR_PATH}
# RUN ./setup.sh

# EXPOSE 2323
# VOLUME ${CONFIG_PATH}
# VOLUME ${DATA_PATH}
# VOLUME ${MODULES_PATH}

# ENTRYPOINT [ "./run.sh" ]
