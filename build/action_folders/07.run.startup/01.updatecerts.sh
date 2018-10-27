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
    alpine)
        update-ca-certificates -f ||:
        ;;
    centos|fedora)
        update-ca-trust extract ||:
        ;;
    ubuntu)
        ;;
esac

# skip the rest if Java is not installed with keytool
[ "${JAVA_HOME:-}" ] || exit 0
type -f keytool &> /dev/null || exit 0

#############################################################################
# Continue onwards for java cacert
#############################################################################

while read -r cert; do
    aliasname=DellEMC_${cert%.*}
    echo "$aliasname -> $cert into ${JAVA_HOME}"
    keytool -noprompt \
            -storepass changeit \
            -keystore "${JAVA_HOME}/lib/security/cacerts" \
            -import -alias "$cert" \
            -file "${cert_home}/${cert}" \
    || echo "Failed to load $cert into JVM cacert"
done < <(cd "${cert_home}"; ls -1A)
