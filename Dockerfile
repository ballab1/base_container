ARG FROM_BASE
FROM ${FROM_BASE} 

# name and version of this docker image
ARG CONTAINER_NAME=base_container

# include our project files
COPY build Dockerfile /tmp/

# set to non zero for the framework to show verbose action scripts
#    (0:default, 1:trace & do not cleanup; 2:continue after errors)
ENV DEBUG_TRACE=0

# Specify CBF version to use with our configuration and customizations
ARG CBF_VERSION=master
LABEL cbf.version=$CBF_VERSION


# set timezone in base, so we do not need to do this again
ARG TZ="America/New_York"
ENV TZ="${TZ:-America/New_York}"


# build content
RUN set -o verbose \
    && chmod u+rwx /tmp/build.sh \
    && /tmp/build.sh "$CONTAINER_NAME" "$DEBUG_TRACE" "$TZ"
RUN [ $DEBUG_TRACE != 0 ] || rm -rf /tmp/*
