#!/bin/bash

set -o errexit
set -o nounset

#############################################################################
#
#   download.sh
#
#############################################################################
function download.get_file()
{
    local -r file=${1:?'Input parameter "file" must be defined'}

    # load download definition
    source "$file"
    local name="$( basename "$file" )"
    $LOG "Downloading from definition:  ${name}${LF}" 'task'

    # strip path & prefix from file to get name
    name="${name//[0-9]/}"
    name="${name#.}"

    # derefernce our params
    local -A params=( ['file']="$( lib.indirect_reference $name 'file' )" \
                      ['url']="$( lib.indirect_reference $name 'url' )" \
                      ['sha256']="$( lib.indirect_reference $name 'sha256' )" \
                    )
    $LOG "....file:  ${params['file']}${LF}" 'info'
    $LOG ".....url:  ${params['url']}${LF}" 'info'
    $LOG "..sha256:  ${params['sha256']}${LF}" 'info'

    local -i attempt
    for attempt in {0..3}; do
        [ $attempt -eq 3 ] && exit 1
        wget -O "${params['file']}" --no-check-certificate "${params['url']}"
        [ $? -ne 0 ] && continue
        local result=$(echo "${params['sha256']}  ${params['file']}" | sha256sum -cw 2>&1)
        $LOG "${result}${LF}" 'info'
        [ $result != *' WARNING: '* ] && return 0
        $LOG "..failed to successfully download ${params['file']}. Retrying....${LF}" 'warn'
    done
    exit 0
}


#############################################################################
function download.get_packages()
{
    local -r dir=${1:?'Input parameter "dir" must be defined'}
    
    while read pkg; do
        eval download.get_file "$pkg" || $LOG "..*** issue while downloading $( basename "$pkg" ) ***${LF}" 'warn'
    done < <(ls -1 "${TOOLS}/${dir}"/* 2>/dev/null | sort)
}
