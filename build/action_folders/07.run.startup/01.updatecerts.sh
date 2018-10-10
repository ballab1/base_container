#!/bin/bash

declare -r cert_home=/usr/local/share/ca-certificates

#############################################################################
# Update certs on system
#############################################################################
# copy kubernetes read-only mounted secrets over to expected directory
cp -f /mnt/data/ca-certificates/* ${cert_home}/ ||:

# load certs via system
update-ca-certificates -f

# skip the rest if Java is not installed with keytool
if ! type -f keytool &> /dev/null; then
    exit 0
fi

#############################################################################
# Continue onwards for java cacert
#############################################################################

# add custom SSL if found in /usr/local/share/ca-certificates
declare -r jre_home=$( readlink -f $(dirname $(readlink -f $(which java)))/.. )
export JAVA_HOME=$jre_home
export PATH="${PATH}:$JAVA_HOME/bin"

function keytool_cmd() {
    keytool -noprompt -storepass changeit -keystore "${JAVA_HOME}/lib/security/cacerts" "$@"
}

for cert in $cert_home/*; do
    aliasname=$(basename $cert)
    aliasname=DellEMC_${aliasname%.*}
    echo "$aliasname -> $cert into ${JAVA_HOME}"
    keytool_cmd -import -alias "$aliasname" -file ${cert} || echo "Failed to load $cert into JVM cacert"
done
