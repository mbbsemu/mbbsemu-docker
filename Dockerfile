FROM mcr.microsoft.com/dotnet/core/runtime:3.1.1-buster-slim

COPY pkg/modules /bbsv6/
COPY pkg/mbbsemu-linux-x64-* /mbbsemu

COPY setup.sh /mbbsemu
RUN /mbbsemu/setup.sh

COPY run.sh /

EXPOSE 23

CMD [ "/bin/bash" ]
