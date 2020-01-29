FROM mcr.microsoft.com/dotnet/core/runtime:3.1.1-buster-slim

LABEL maintainer="fletcherm@gmail.com"

ENV INSTALL_PATH /mbbsemu/

COPY pkg/modules /bbsv6/
COPY pkg/mbbsemu-linux-x64-* ${INSTALL_PATH}
COPY run.sh setup.sh ${INSTALL_PATH}

WORKDIR ${INSTALL_PATH}
RUN ./setup.sh

EXPOSE 23
VOLUME /data

ENTRYPOINT [ "./run.sh" ]
