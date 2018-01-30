#!/bin/bash
#############################################################################
#
#   lib.sh
#
#############################################################################
function lib.build_container()
{
    local -r name=${1:?'Input parameter "name" must be defined'}
    local -r timezone=${2:-null}
    export TOOLS=$( lib.get_base )
    
    term.header "$name"
    lib.run_scripts '02.packages' 'Install OS Support'
    [ "$timezone" != null ] && package.installTimezone "$timezone"
    uidgid.check '03.users_groups' 'Verify users and groups'
    download.get_packages '04.downloads'
    lib.run_scripts '05.applications' 'Install applications'
    lib.run_scripts '06.customizations' 'Add configuration and customizations'
    lib.run_scripts '07.permissions' 'Make sure that ownership & permissions are correct'
    lib.run_scripts '08.cleanup' 'Clean up'
}

#############################################################################
function lib.get_base()
{
    printf "%s" "$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"   
}

#############################################################################
function lib.indirect_reference()
{
    local -r hash=${1:?'Input parameter "hash" must be defined'}
    local -r key=${2:?'Input parameter "key" must be defined'}

    eval "echo \${$hash[$key]}"
}

#############################################################################
function lib.run_scripts()
{
    local -r dir=${1:?'Input parameter "dir" must be defined'}
    local -r notice=${2:-' '}
    local -r tools="$( lib.get_base )"

    IFS=$'\r\n'
    local files="$(ls -1 "${tools}/${dir}"/* 2>/dev/null | sort)"
    if [ "$files" ]; then
        [ "$notice" != ' ' ] && $LOG "${notice}${LF}" 'task'
        for file in ${files} ; do
            chmod 755 "$file"
            $LOG "..executing ${file}${LF}" 'info'
            eval "$file" || $LOG "..*** issue while executing $( basename "$file" ) ***${LF}" 'warn'
        done
    fi
}
