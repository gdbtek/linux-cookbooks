#!/bin/bash

function installDependencies()
{
    runAptGetUpdate
}

function install()
{
    echo "${timeZone}" > '/etc/timezone'
    dpkg-reconfigure -f noninteractive tzdata
    apt-get install -y ntp
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
