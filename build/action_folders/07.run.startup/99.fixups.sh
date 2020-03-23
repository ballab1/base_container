#!/bin/bash

declare -ra exceptions=(''
                         /
                         /dev
                         /etc
                         /lib
                         /lib64
                         /proc
                         /root
                         /run
                         /sbin
                         /sys
                         /usr/bin
                         /usr/local/bin
                         /usr/local/crf/startup
                         /var/run
                        )


declare -a fixup_dirs=( /var/log ) # always fixup the log dir
[ "${FIXUPDIRS:-}" ] && fixup_dirs+=( "${FIXUPDIRS[@]}" )                 # use 'FIXUPDIRS' from scripted code

# BASH does not have ability to export arrays : FIXUPDIRS is internal and can be set. CBF_FIXUPDIRS is external so need to use a file
[[ "${CBF_FIXUPDIRS:-}" && -e "${CBF_FIXUPDIRS:-}" ]] && fixup_dirs+=( $(< "$CBF_FIXUPDIRS") )

declare dir ex
for dir in "${fixup_dirs[@]}"; do
    [ -z "${dir:-}" ] && continue
    for ex in "${exceptions[@]}"; do
        if [ "$dir" = "$ex" ]; then
            term.elog "setting of '$dir' not permitted. Ignoring" 'yellow'
            continue 2
        fi
    done
    crf.fixupDirectory "$dir"
done

# make sure we can read/write everythin on /var/log
declare x
for x in $(find /var/log -type d); do
    chmod 777 "$x"
done
for x in $(find /var/log -type f); do
    chmod a+rw "$x"
done

