#!/bin/bash -e

function install()
{
    echo "${NTP_TIME_ZONE}" > '/etc/timezone'
    dpkg-reconfigure -f noninteractive tzdata 2> '/dev/null'
    installAptGetPackages 'ntp'
}

function main()
{
    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../../../libraries/util.bash"
    source "${appFolderPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING NTP'

    install
    installCleanUp
}

main "${@}"