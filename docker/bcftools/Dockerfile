# use the ubuntu base image
FROM ubuntu:20.04

LABEL maintainer="Tim Sanders <tsanders@mednet.ucla.edu>"

RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
    curl \
    autoconf \
    build-essential \
    cmake \
    g++ \
    gfortran \
    libcurl4-gnutls-dev \
    hdf5-tools \
    libboost-date-time-dev \
    libboost-program-options-dev \
    libboost-system-dev \
    libboost-filesystem-dev \
    libboost-iostreams-dev \
    libbz2-dev \
    libhdf5-dev \
    libncurses-dev \
    liblzma-dev \
    zlib1g-dev

ADD https://github.com/samtools/bcftools/releases/download/1.11/bcftools-1.11.tar.bz2
RUN tar -jxf bcftools-1.11.tar.bz2 \
    && rm bcftools-1.11.tar.bz2

WORKDIR bcftools-1.11

RUN make \
    && make install \
    && export PATH=/usr/local/bin:$PATH

FROM alpine:3.13
ENV PATH /app/vcftools-0.1.16/bin:$PATH
RUN apk add --no-cache libstdc++ zlib
RUN apk add --update bash && rm -rf /var/cache/apk/*
COPY --from=builder /app/ /app/