FROM blcdsdockerregistry/bl-base:1.0.0 as builder

# Use conda to install tools and dependencies into /usr/local
ENV RTG_VERSION=3.11
RUN conda create -qy -p /usr/local \
    -c bioconda \
    -c conda-forge \
    rtg-tools==${RTG_VERSION}

# Deploy the target tools into a base image
FROM ubuntu:20.04
COPY --from=builder /usr/local /usr/local

LABEL maintainer="Tim Sanders <tsanders@mednet.ucla.edu>"

# RTG Tools requires you answer whether or not you want to enable automatic usage reporting (via 'rtg help')
# so this line passes "n" to that prompt after extraction
# CMD echo "n" | rtg help
