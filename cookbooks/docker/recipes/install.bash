#!/bin/bash -e

function install()
{
    umask '0022'

    if [[ "$(isAmazonLinuxDistributor)" = 'true' ]]
    then
        amazon-linux-extras install -y 'docker'
        systemctl status 'docker'
    elif [[ "$(isUbuntuDistributor)" = 'true' ]]
    then
        checkExistURL "${DOCKER_DOWNLOAD_URL}"
        curl -L "${DOCKER_DOWNLOAD_URL}" --retry 12 --retry-delay 5 | bash -e
        systemctl status 'docker'
    else
        fatal 'FATAL : only support Amazon-Linux, or Ubuntu OS'
    fi

    umask '0077'
}

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    header 'INSTALLING DOCKER'

    checkRequireLinuxSystem
    checkRequireRootUser

    install
    installCleanUp
}

main "${@}"