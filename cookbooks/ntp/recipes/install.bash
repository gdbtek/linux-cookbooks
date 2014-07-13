#!/bin/bash

function installDependencies()
{
    runAptGetUpdate
}

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

    checkRequireDistributor

    header 'INSTALLING NTP'

    checkRequireRootUser

    installDependencies
    install
    installCleanUp
}

main "${@}"