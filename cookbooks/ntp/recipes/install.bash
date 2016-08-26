#!/bin/bash -e

function install()
{
    if [[ "$(isUbuntuDistributor)" = 'true' ]]
    then
        echo "${NTP_TIME_ZONE}" > '/etc/timezone'
        dpkg-reconfigure -f noninteractive tzdata 2> '/dev/null'
        installPackages 'ntp'
    elif [[ "$(isCentOSDistributor)" = 'true' || "$(isRedHatDistributor)" = 'true' ]]
    then
        yum install -y 'ntp'
        timedatectl set-timezone "${NTP_TIME_ZONE}"
    else
        fatal '\nFATAL : only support CentOS, RedHat or Ubuntu OS'
    fi
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