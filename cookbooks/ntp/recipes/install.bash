#!/bin/bash -e

function install()
{
    echo "${NTP_TIME_ZONE:?}" > '/etc/timezone'
    dpkg-reconfigure -f noninteractive tzdata 2> '/dev/null'
    installAptGetPackages 'ntp'
}

function main()
{
    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING NTP'

    install
    installCleanUp
}

main "${@}"