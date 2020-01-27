FROM mcr.microsoft.com/dotnet/core/runtime:3.1.1-buster-slim

COPY pkg/ /

EXPOSE 23

CMD [ "/bin/bash" ]
