FROM mcr.microsoft.com/dotnet/core/runtime:3.1.1-buster-slim

LABEL maintainer="fletcherm@gmail.com"

ENV CONFIG_PATH /config
ENV DATA_PATH /data
ENV EMULATOR_PATH /mbbsemu
ENV MODULES_PATH /modules

COPY pkg/mbbsemu-linux-x64-* ${EMULATOR_PATH}
COPY run.sh ${EMULATOR_PATH}
COPY setup.sh ${EMULATOR_PATH}

WORKDIR ${EMULATOR_PATH}
RUN ./setup.sh

EXPOSE 2323
VOLUME ${CONFIG_PATH}
VOLUME ${DATA_PATH}
VOLUME ${MODULES_PATH}

ENTRYPOINT [ "./run.sh" ]
