ARG  CODE_BASE=alpine:3.6
FROM ${CODE_BASE}

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
    && /tmp/container/build.sh 'BASE' "$TZ"
RUN rm -rf /tmp/*

SHELL [ "/bin/bash" ]    
ENTRYPOINT [ "docker-entrypoint.sh" ]
