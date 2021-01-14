FROM alpine:3.12 as builder

LABEL maintainer="Tim Sanders <tsanders@mednet.ucla.edu>"

RUN apk --no-cache add alpine-sdk perl zlib-dev curl
RUN set -ex \
    && curl -L -O https://github.com/vcftools/vcftools/releases/download/v0.1.16/vcftools-0.1.16.tar.gz \
    && tar zxf vcftools-0.1.16.tar.gz \
    && rm vcftools-0.1.16.tar.gz \
    && cd vcftools-0.1.16 \
    && ./configure --prefix=/app/vcftools-0.1.16 \
    && make \
    && make install

FROM alpine:3.12
ENV PATH /app/vcftools-0.1.16/bin:$PATH
ENV PERL5LIB /app/vcftools-0.1.16/share/perl:$PERL5LIB
RUN apk add --no-cache libstdc++ perl zlib
RUN apk add --update bash && rm -rf /var/cache/apk/*
COPY --from=builder /app/ /app/