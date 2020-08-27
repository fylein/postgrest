FROM debian:buster-slim as build

ARG STACK_VERSION=2.3.3

ENV PATH /root/.local/bin:$PATH

# Install dependencies
RUN apt-get -qq update && \
    apt-get -qq install -y --no-install-recommends libpq-dev pkg-config libpcre3 libpcre3-dev postgresql-client debconf \
        locales g++ gcc libc6-dev libffi-dev libgmp-dev make xz-utils zlib1g-dev git gnupg netbase curl ca-certificates && \
    echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen && \
    locale-gen && \
    echo 'export LC_ALL=en_US.UTF-8' >> /etc/profile && \
    cd /tmp && \
    curl -SLO https://github.com/commercialhaskell/stack/releases/download/v${STACK_VERSION}/stack-${STACK_VERSION}-linux-x86_64.tar.gz && \
    tar -xzvf stack-${STACK_VERSION}-linux-x86_64.tar.gz && \
    mv stack-${STACK_VERSION}-linux-x86_64/stack /usr/local/bin/stack && \
    cd / && \
    apt-get -qq clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir /opt/build

COPY docker /opt/build

# Build postgrest app
RUN cd /opt/build && \
    stack build --system-ghc --copy-bins --local-bin-path /usr/local/bin && \
    cd /

FROM debian:stretch-slim

# Install libpq5
RUN apt-get -qq update && \
    apt-get -qq install -y --no-install-recommends libpq5 && \
    apt-get -qq clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy `postgrest` binary from previous build
COPY --from=build /usr/local/bin/postgrest /usr/local/bin/postgrest

COPY postgrest.conf /etc/postgrest.conf


ENV PGRST_DB_URI= \
    PGRST_DB_SCHEMA=public \
    PGRST_DB_ANON_ROLE= \
    PGRST_DB_POOL=100 \
    PGRST_DB_EXTRA_SEARCH_PATH=public \
    PGRST_SERVER_HOST=*4 \
    PGRST_SERVER_PORT=3000 \
    PGRST_OPENAPI_SERVER_PROXY_URI= \
    PGRST_JWT_SECRET= \
    PGRST_SECRET_IS_BASE64=false \
    PGRST_JWT_AUD= \
    PGRST_MAX_ROWS= \
    PGRST_PRE_REQUEST= \
    PGRST_ROLE_CLAIM_KEY=".role" \
    PGRST_ROOT_SPEC= \
    PGRST_RAW_MEDIA_TYPES=

RUN groupadd -g 1000 postgrest && \
    useradd -r -u 1000 -g postgrest postgrest && \
    chown postgrest:postgrest /etc/postgrest.conf

USER 1000

# PostgREST reads /etc/postgrest.conf so map the configuration
# file in when you run this container
CMD exec postgrest /etc/postgrest.conf

EXPOSE 3000
