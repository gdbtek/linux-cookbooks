#!/bin/bash -e

function install()
{
    local -r disk="$(formatPath "${1}")"
    local -r mountOn="$(formatPath "${2}")"

    # Create Partition

    checkNonEmptyString "${disk}" 'undefined disk'
    checkNonEmptyString "${mountOn}" 'undefined mount-on'

    if [[ "$(existDisk "${disk}")" = 'false' ]]
    then
        fatal "FATAL : disk '${disk}' not found"
    fi

    local -r newDisk="${disk}${MOUNT_HD_PARTITION_NUMBER}"

    if [[ -d "${mountOn}" ]]
    then
        if [[ "$(existDiskMount "${newDisk}" "${mountOn}")" = 'false' ]]
        then
            fatal "FATAL : mount-on '${mountOn}' found"
        fi

        info "Already mounted '${newDisk}' to '${mountOn}'\n"
        df -h -T
    else
        createPartition "${disk}"
        mkfs -t "${MOUNT_HD_FS_TYPE}" "${newDisk}"
        mkdir "${mountOn}"
        mount -t "${MOUNT_HD_FS_TYPE}" "${newDisk}" "${mountOn}"

        # Config Static File System

        local -r fstabPattern="^\s*${newDisk}\s+${mountOn}\s+${MOUNT_HD_FS_TYPE}\s+${MOUNT_HD_MOUNT_OPTIONS}\s+${MOUNT_HD_DUMP}\s+${MOUNT_HD_FSCK_OPTION}\s*$"
        local -r fstabConfig="${newDisk} ${mountOn} ${MOUNT_HD_FS_TYPE} ${MOUNT_HD_MOUNT_OPTIONS} ${MOUNT_HD_DUMP} ${MOUNT_HD_FSCK_OPTION}"

        appendToFileIfNotFound '/etc/fstab' "${fstabPattern}" "${fstabConfig}" 'true' 'false' 'true'

        # Display File System

        df -h -T
    fi
}

function createPartition()
{
    local -r disk="${1}"

    installAptGetPackages 'expect'

    expect << DONE
        spawn fdisk "${disk}"

        expect "Command (m for help): "
        send -- "n\r"

        expect "Select (default p): "
        send -- "\r"

        expect "Partition number (1-4, default 1): "
        send -- "\r"

        expect "First sector (*, default *): "
        send -- "\r"

        expect "Last sector, +sectors or +size{K,M,G} (*, default *): "
        send -- "\r"

        expect "Command (m for help): "
        send -- "w\r"

        expect eof
DONE
}

function main()
{
    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING MOUNT-HD'

    install "${@}"
    installCleanUp
}

main "${@}"