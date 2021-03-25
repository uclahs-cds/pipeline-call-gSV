# use the ubuntu base image
FROM ubuntu:20.04

LABEL maintainer="Tim Sanders <tsanders@mednet.ucla.edu>"

# install required packages
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    autoconf \
    build-essential \
    ca-certificates \
    cmake \
    g++ \
    gfortran \
    git \
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
    zlib1g-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# set environment
ENV BOOST_ROOT /usr

# install delly
RUN cd /opt \
    && git clone --recursive https://github.com/dellytools/delly.git --branch v0.8.7 \
    && cd /opt/delly/ \
    && make STATIC=1 all \
    && make install


# Multi-stage build
FROM alpine:3.13
RUN mkdir -p /opt/delly/bin
WORKDIR /opt/delly/bin
COPY --from=0 /opt/delly/bin/delly .

RUN apk add --update bash && rm -rf /var/cache/apk/*

# Workdir
WORKDIR /root/

# Add Delly to PATH
ENV PATH="/opt/delly/bin:${PATH}"

CMD ["/bin/sh"]
