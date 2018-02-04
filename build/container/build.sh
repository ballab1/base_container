#!/bin/bash

#set -o xtrace
set -o errexit
set -o nounset 
#set -o verbose

declare NAME=${1:?'Input parameter "NAME" must be defined'} 
declare TZ="${2:-null}"

# load our libraries
declare -r lib_base="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"  
for src in "${lib_base}/01.bashlib"/*.sh ; do
    source "$src"
done


# build our container
lib.buildContainer "$NAME" "$TZ"

