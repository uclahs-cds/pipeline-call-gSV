FROM ubuntu:20.04

LABEL maintainer="Tim Sanders <tsanders@mednet.ucla.edu>"

RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
    unzip

ADD https://github.com/RealTimeGenomics/rtg-tools/releases/download/3.11/rtg-tools-3.11-linux-x64.zip /

# RTG Tools requires you answer whether or not you want to enable automatic usage reporting (via 'rtg help')
# so this line passes "n" to that prompt after extraction
RUN unzip rtg-tools-3.11-linux-x64.zip \
    && rm rtg-tools-3.11-linux-x64.zip \
    && echo "n" | /rtg-tools-3.11/rtg help

WORKDIR rtg-tools-3.11

ENV PATH="/rtg-tools-3.11:${PATH}"