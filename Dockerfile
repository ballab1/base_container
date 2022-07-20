ARG FROM_BASE=${DOCKER_REGISTRY:-s2.ubuntu.home:5000/}thirdparty/${CONTAINER_OS:-alpine}:${OS_VERSION:-3.15.4} 
FROM ${FROM_BASE} 

# name and version of this docker image
ARG CONTAINER_NAME=base_container
# Specify CBF version to use with our configuration and customizations
ARG CBF_VERSION

# include our project files
COPY build Dockerfile /tmp/

# set to non zero for the framework to show verbose action scripts
#    (0:default, 1:trace & do not cleanup; 2:continue after errors)
ENV DEBUG_TRACE=0


# set timezone in base, so we do not need to do this again
ARG TZ="UTC"
ENV TZ="${TZ:-UTC}"


# build content
RUN set -o verbose \
    && chmod u+rwx /tmp/build.sh \
    && /tmp/build.sh "$CONTAINER_NAME" "$DEBUG_TRACE" "$TZ" \
    && ([ "$DEBUG_TRACE" != 0 ] || rm -rf /tmp/*)
