#!/bin/bash

function installDependencies()
{
    apt-get update
}

function install()
{
    echo "${timeZone}" > "${etcTimeZoneFile}"
    dpkg-reconfigure -f noninteractive tzdata
    apt-get install -y ntp
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    header 'INSTALLING NTP'

    checkRequireRootUser

    installDependencies
    install
}

main "${@}"
