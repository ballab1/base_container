ARG FROM_BASE=alpine:3.6
FROM ${FROM_BASE} 

# version of this docker image
ARG CONTAINER_VERSION=1.0.0 
LABEL version=$CONTAINER_VERSION  

# set timezone in base, so we do not need to do this again
ARG TZ="America/New_York"
ENV TZ "$TZ"

# set to non zero for the framework to show verbose action scripts
ARG DEBUG_TRACE=0

# Add configuration and customizations
COPY build /tmp/

# build content
RUN set -o verbose \
    && apk update \
    && apk add --no-cache bash \
    && chmod u+rwx /tmp/build.sh \
    && /tmp/build.sh 'BASE' "$TZ"
#RUN rm -rf /tmp/*
