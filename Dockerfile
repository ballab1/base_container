FROM alpine:3.6

ARG TZ='America/New_York'

ENV VERSION=1.0.0 \
    TZ="$TZ"
LABEL version=$VERSION

# Add configuration and customizations
COPY build /tmp/

# build content
RUN set -o verbose \
    && apk update \
    && apk add --no-cache bash \
    && chmod u+rwx /tmp/container/build.sh \
    && /tmp/container/build.sh 'BASE' "$TZ" \
    && rm -rf /tmp/*
    
ENTRYPOINT [ "docker-entrypoint.sh" ]
