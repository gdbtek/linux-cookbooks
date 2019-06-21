#!/bin/bash -e

function extend()
{
    local -r disk="${1}"
    local -r mountOn="${2}"

    umask '0022'

    if [[ "$(existDisk "${disk}")" = 'true' ]]
    then
        if [[ "$(existDiskMount "${disk}${MOUNT_HD_PARTITION_NUMBER}" "${mountOn}")" = 'false' ]]
        then
            rm -f -r -v "${mountOn}"
            "$(dirname "${BASH_SOURCE[0]}")/install.bash" "${disk}" "${mountOn}"
        else
            info "Already mounted '${disk}${MOUNT_HD_PARTITION_NUMBER}' to '${mountOn}'\n"
            df -h -T
        fi
    else
        info "Extended volume '${disk}' not found"
    fi

    umask '0077'
}

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    header 'EXTENDING MOUNT-HD'

    checkRequireLinuxSystem
    checkRequireRootUser

    extend "${@}"
    installCleanUp
}

main "${@}"