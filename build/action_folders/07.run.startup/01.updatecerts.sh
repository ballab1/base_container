#!/bin/bash

declare -r cert_home=/usr/local/share/ca-certificates

#############################################################################
# Update certs on system
#############################################################################
# copy kubernetes read-only mounted secrets over to expected directory
if [ -d /mnt/data/ca-certificates ]; then
    cp -f /mnt/data/ca-certificates/* "${cert_home}/" ||:
fi

# load certs via system
case "$( environ.OSid )" in
    alpine|ubuntu)
        update-ca-certificates -f 1>&2 ||:
        ;;
    centos|fedora)
        update-ca-trust extract 1>&2 ||:
        ;;
esac

# skip the rest if Java is not installed with keytool
[ "${JAVA_HOME:-}" ] || exit 0
type -f keytool &> /dev/null || exit 0

#############################################################################
# Continue onwards for java cacert
#############################################################################

# Readlink to find out location diff between JDK and JRE installation
declare -r java_cert_home=$(readlink -f $(dirname $(readlink -f $(which java)))/../lib/security/cacerts)
while read -r cert; do
    aliasname=DellEMC_${cert%.*}
    echo "$aliasname -> $cert into ${java_cert_home}"
    keytool -noprompt \
            -storepass changeit \
            -keystore "${java_cert_home}" \
            -import -alias "$cert" \
            -file "${cert_home}/${cert}" \
    || echo "Failed to load $cert into JVM cacert"
done < <(cd "${cert_home}"; ls -1A)
