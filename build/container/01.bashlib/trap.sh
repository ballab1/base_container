#!/bin/bash
#############################################################################
#
#   trap.sh
#
#----------------------------------------------------------------------------

# global exceptions
declare -i dying=0
declare -i pipe_error=0

#----------------------------------------------------------------------------
# Exit on any error
function trap.catch_error() {
    trap.die "ERROR: an unknown error occurred at $BASH_SOURCE:$BASH_LINENO"
}

#----------------------------------------------------------------------------
# Detect when build is aborted
function trap.catch_int() {
    trap.die "${BASH_SOURCE[0]} has been aborted with SIGINT (Ctrl-C)"
}

#----------------------------------------------------------------------------
function trap.catch_pipe() {
    pipe_error+=1
    [[ $pipe_error -eq 1 ]] || return 0
    [[ $dying -eq 0 ]] || return 0
    trap.die "${BASH_SOURCE[0]} has been aborted with SIGPIPE (broken pipe)"
}

#----------------------------------------------------------------------------
function trap.die() {
    local status=$?
    [[ $status -ne 0 ]] || status=255
    dying+=1

    $( $LOG "${LF}FATAL ERROR: $@${LF}" 'error' ) >&2
    exit $status
}  

trap trap.catch_error ERR
trap trap.catch_int INT
trap trap.catch_pipe PIPE 

