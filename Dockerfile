ARG FROM_BASE=alpine:3.6
FROM ${FROM_BASE} 

# version of this docker image
ARG CONTAINER_VERSION=1.0.0 
LABEL version=$CONTAINER_VERSION  

ENV TZ="$TZ"

# version of this docker image
LABEL version=$CONTAINER_VERSION  

# Add configuration and customizations
COPY build /tmp/

# build content
RUN set -o verbose \
    && apk update \
    && apk add --no-cache bash \
    && chmod u+rwx /tmp/container/build.sh \
    && /tmp/container/build.sh 'BASE' "$TZ"
RUN rm -rf /tmp/*
