FROM mcr.microsoft.com/dotnet/core/runtime:3.1.1-buster-slim

COPY pkg/mbbsemu-linux-x64-* /mbbsemu
COPY pkg/modules /bbsv6/

EXPOSE 23

CMD [ "/bin/bash" ]
