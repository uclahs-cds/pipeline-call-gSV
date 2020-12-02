# use the ubuntu base image
FROM ubuntu:18.04

LABEL maintainer="tsanders@mednet.ucla.edu"

RUN apt update && apt install -y \
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

RUN curl -OL https://github.com/samtools/bcftools/releases/download/1.11/bcftools-1.11.tar.bz2

RUN tar -jxf bcftools-1.11.tar.bz2

RUN rm bcftools-1.11.tar.bz2

WORKDIR bcftools-1.11

RUN /bin/bash -c 'make'

RUN /bin/bash -c 'make install'

RUN /bin/bash -c 'export PATH=/usr/local/bin:$PATH'

# by default /bin/bash is executed
CMD ["/bin/bash"]
