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
            "${APP_FOLDER_PATH}/install.bash" "${disk}" "${mountOn}"
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
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'EXTENDING MOUNT-HD'

    extend "${@}"
    installCleanUp
}

main "${@}"