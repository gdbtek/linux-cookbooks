#!/bin/bash -e

function install()
{
    umask '0022'

    installPackages 'ntp'

    if [[ "$(isUbuntuDistributor)" = 'true' || "$(isCentOSDistributor)" = 'true' || "$(isRedHatDistributor)" = 'true' ]]
    then
        timedatectl set-timezone "${NTP_TIME_ZONE}"
    else
        fatal '\nFATAL : only support CentOS, RedHat or Ubuntu OS'
    fi

    umask '0077'
}

function main()
{
    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../../../libraries/util.bash"
    source "${appFolderPath}/../attributes/default.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING NTP'

    install
    installCleanUp
}

main "${@}"