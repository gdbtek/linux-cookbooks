#!/bin/bash -e

function install()
{
    umask '0022'

    if [[ "$(isAmazonLinuxDistributor)" = 'true' || "$(isCentOSDistributor)" = 'true' || "$(isRedHatDistributor)" = 'true' ]]
    then
        setenforce 0 || true
    fi

    timedatectl set-timezone "${CHRONY_TIME_ZONE}"

    if [[ "$(isAmazonLinuxDistributor)" = 'true' || "$(isCentOSDistributor)" = 'true' || "$(isRedHatDistributor)" = 'true' ]]
    then
        setenforce 1 || true
    fi

    installPackages 'chrony'
    mkdir -p '/var/log/chrony'
    chmod 755 '/var/log/chrony'

    if [[ "$(isUbuntuDistributor)" = 'true' ]]
    then
        chown -R '_chrony:_chrony' '/var/log/chrony'
        restartService 'chrony'
    else
        chown -R 'chrony:chrony' '/var/log/chrony'
        restartService 'chronyd'
    fi

    header 'DISPLAYING CURRENT DATE TIME'
    info "$(date)"

    umask '0077'
}

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    header 'INSTALLING CHRONY'

    checkRequireLinuxSystem
    checkRequireRootUser

    install
    installCleanUp
}

main "${@}"