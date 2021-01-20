FROM ubuntu:20.04

LABEL maintainer="Tim Sanders <tsanders@mednet.ucla.edu>"

RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y \
    curl \
    unzip

RUN curl -OL https://github.com/RealTimeGenomics/rtg-tools/releases/download/3.11/rtg-tools-3.11-linux-x64.zip \
    && unzip rtg-tools-3.11-linux-x64.zip -d /rtgtools


FROM alpine:3.13
RUN apk add --update bash && rm -rf /var/cache/apk/*
COPY --from=0 /rtgtools /rtgtools