ARG FROM_BASE=alpine:3.6
FROM ${FROM_BASE} 

# name and version of this docker image
ARG CONTAINER_NAME=base_container
ARG CONTAINER_VERSION=1.0.0

LABEL org_name=$CONTAINER_NAME \
      version=$CONTAINER_VERSION 

# set to non zero for the framework to show verbose action scripts
ARG DEBUG_TRACE=0


# set timezone in base, so we do not need to do this again
ARG TZ="America/New_York"
ENV TZ="$TZ"


# Add configuration and customizations
COPY build /tmp/

# build content
RUN set -o verbose \
    && echo http://mirror.yandex.ru/mirrors/alpine/v3.5/main >> /etc/apk/repositories \
    && echo http://mirror.yandex.ru/mirrors/alpine/v3.5/community >> /etc/apk/repositories \
    && apk update \
    && apk add --no-cache bash \
    && chmod u+rwx /tmp/build.sh \
    && /tmp/build.sh "$CONTAINER_NAME" "$TZ"
RUN [[ $DEBUG_TRACE != 0 ]] || rm -rf /tmp/* 
