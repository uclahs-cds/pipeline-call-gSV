FROM ubuntu:20.04

LABEL maintainer="Tim Sanders <tsanders@mednet.ucla.edu>"

RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
    unzip

ADD https://github.com/RealTimeGenomics/rtg-tools/releases/download/3.11/rtg-tools-3.11-linux-x64.zip /
RUN unzip rtg-tools-3.11-linux-x64.zip \
    && rm rtg-tools-3.11-linux-x64.zip

WORKDIR rtg-tools-3.11

ENV PATH="/rtg-tools-3.11:${PATH}"

RUN echo "n" | rtg help