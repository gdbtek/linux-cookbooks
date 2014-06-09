#!/bin/bash

function installDependencies()
{
    runAptGetUpdate

    apt-get install -y expect
}

function install()
{
    local disk="$(formatPath "${1}")"
    local mountOn="$(formatPath "${2}")"

    local foundDisk="$(fdisk -l "${disk}" 2>/dev/null | grep -Eio "^Disk\s+$(escapeSearchPattern "${disk}"):")"

    if [[ "$(isEmptyString "${foundDisk}")" = 'true' ]]
    then
        fatal "\nFATAL: disk '${disk}' not found"
    fi

    if [[ "$(isEmptyString "${mountOn}")" = 'true' || -d "${mountOn}" ]]
    then
        fatal "FATAL: mounted file system '${mountOn}' found or undefined"
    fi

    createPartition "${disk}"
    mkfs.ext4 "${disk}1"
    mkdir "${mountOn}"
    mount -t ext4 "${disk}1" "${mountOn}"

    df -h
}

function createPartition()
{
    local disk="${1}"

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
    local appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1

    checkRequireDistributor

    header 'INSTALLING MOUNT-HD'

    checkRequireRootUser

    installDependencies
    install "${@}"
    installCleanUp
}

main "${@}"
