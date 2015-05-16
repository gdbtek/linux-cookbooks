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

    local -r newDisk="${disk}${mounthdPartitionNumber}"

    if [[ -d "${mountOn}" ]]
    then
        if [[ "$(existDiskMount "${newDisk}" "${mountOn}")" = 'true' ]]
        then
            info "Already mounted '${newDisk}' to '${mountOn}'\n"
            df -h -T
        else
            fatal "FATAL : mount-on '${mountOn}' found"
        fi
    else
        createPartition "${disk}"
        mkfs -t "${mounthdFSType}" "${newDisk}"
        mkdir "${mountOn}"
        mount -t "${mounthdFSType}" "${newDisk}" "${mountOn}"

        # Config Static File System

        local -r fstabPattern="^\s*${newDisk}\s+${mountOn}\s+${mounthdFSType}\s+${mounthdMountOptions}\s+${mounthdDump}\s+${mounthdFSCKOption}\s*$"
        local -r fstabConfig="${newDisk} ${mountOn} ${mounthdFSType} ${mounthdMountOptions} ${mounthdDump} ${mounthdFSCKOption}"

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