#!/bin/bash -e

function install()
{
    echo "${ntpTimeZone}" > '/etc/timezone'
    dpkg-reconfigure --frontend noninteractive tzdata 2>/dev/null
    installAptGetPackages 'ntp'
}

function main()
{
    local appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING NTP'

    install
    installCleanUp
}

main "${@}"