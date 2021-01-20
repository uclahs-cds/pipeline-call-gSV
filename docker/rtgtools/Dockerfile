FROM ubuntu:20.04

LABEL maintainer="Tim Sanders <tsanders@mednet.ucla.edu>"

RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y \
    curl \
    unzip

RUN curl -OL https://github.com/RealTimeGenomics/rtg-tools/releases/download/3.11/rtg-tools-3.11-linux-x64.zip \
    && unzip rtg-tools-3.11-linux-x64.zip \
    && rm rtg-tools-3.11-linux-x64.zip \

WORKDIR rtg-tools-3.11

ENV PATH="/rtg-tools-3.11:${PATH}"

RUN echo "n" | rtg help