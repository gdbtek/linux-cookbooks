#!/bin/bash -e

function install()
{
    umask '0022'

    # Set Time Zone

    if [[ "$(isAmazonLinuxDistributor)" = 'true' || "$(isCentOSDistributor)" = 'true' || "$(isRedHatDistributor)" = 'true' ]]
    then
        setenforce 0 || true
    fi

    timedatectl set-timezone "${CHRONY_TIME_ZONE}"

    if [[ "$(isAmazonLinuxDistributor)" = 'true' || "$(isCentOSDistributor)" = 'true' || "$(isRedHatDistributor)" = 'true' ]]
    then
        setenforce 1 || true
    fi

    # Install Package

    installPackages 'chrony'

    # Enable Log and Start Service

    mkdir -p '/var/log/chrony'
    chmod 755 '/var/log/chrony'

    if [[ "$(isUbuntuDistributor)" = 'true' ]]
    then
        chown -R '_chrony:_chrony' '/var/log/chrony'
        startService 'chrony'
    else
        chown -R 'chrony:chrony' '/var/log/chrony'
        startService 'chronyd'
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

    header 'INSTALLING CHRONY'

    install
    installCleanUp
}

main "${@}"