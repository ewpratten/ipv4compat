FROM alpine:3.18 AS builder

# Tayga version
ARG TAYGA_VERSION=0.9.2

# Install build dependencies
RUN apk add --no-cache build-base 
RUN apk add --no-cache linux-headers

# Download and extract tayga
RUN wget -qO- http://www.litech.org/tayga/tayga-${TAYGA_VERSION}.tar.bz2 | tar -xj -C /tmp

# Build tayga
RUN cd /tmp/tayga-${TAYGA_VERSION} && \
    ./configure && \
    make && \
    make install

FROM alpine:3.18

# Install runtime dependencies
RUN apk add --no-cache iproute2
RUN apk add --no-cache bash

# Copy tayga binary
COPY --from=builder /usr/local/sbin/tayga /usr/local/sbin/tayga

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh

# Set entrypoint
ENTRYPOINT ["bash", "/entrypoint.sh"]