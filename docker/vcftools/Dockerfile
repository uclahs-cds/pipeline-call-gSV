# use the ubuntu base image
FROM ubuntu:20.04

LABEL maintainer="Tim Sanders <tsanders@mednet.ucla.edu>"

RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y \
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

RUN curl -OL https://github.com/vcftools/vcftools/releases/download/v0.1.16/vcftools-0.1.16.tar.gz

RUN tar -zxf vcftools-0.1.16.tar.gz

RUN rm vcftools-0.1.16.tar.gz

WORKDIR vcftools-0.1.16

RUN /bin/bash -c './configure'

RUN /bin/bash -c 'make'

RUN /bin/bash -c 'make install'
