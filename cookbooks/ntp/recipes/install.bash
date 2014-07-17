#!/bin/bash

function install()
{
    echo "${ntpTimeZone}" > '/etc/timezone'
    dpkg-reconfigure -f noninteractive tzdata 2>/dev/null
    installAptGetPackages 'ntp'
}

function main()
{
    local appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING NTP'

    install
    installCleanUp
}

main "${@}"