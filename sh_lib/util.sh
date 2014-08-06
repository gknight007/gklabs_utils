#!/usr/bin/bash4

function die () { echo -e "$*" >&2 ; exit 1; }
function warn () { echo -e "$*" >&2 ; }


function get_uuid {
    echo $(cat /proc/sys/kernel/random/uuid 2>/dev/null || uuidgen);
}



function is_pid_running {
    pid="$1"
    found_pid=$(ps --no-headers $pid)
    [ -z "$found_pid" ] && return 1
    return 0
}



