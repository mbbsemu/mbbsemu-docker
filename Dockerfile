FROM mcr.microsoft.com/dotnet/core/runtime:3.1.1-buster-slim

LABEL maintainer="fletcherm@gmail.com"

ENV EMULATOR_PATH /mbbsemu/
ENV MODULES_PATH /modules/

COPY pkg/modules ${MODULES_PATH}
COPY pkg/mbbsemu-linux-x64-* ${EMULATOR_PATH}
COPY run.sh setup.sh ${EMULATOR_PATH}

WORKDIR ${EMULATOR_PATH}
RUN ./setup.sh

EXPOSE 23
VOLUME /data

ENTRYPOINT [ "./run.sh" ]
