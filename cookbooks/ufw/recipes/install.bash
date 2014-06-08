#!/bin/bash

function installDependencies()
{
    apt-get update
}

function install()
{
    apt-get install -y ufw

    # Set Up Policies

    ufw reset
    ufw default deny incoming
    ufw default allow outgoing

    local policy=''

    for policy in "${policies[@]}"
    do
        ufw ${policy}
    done

    # Enable Service

    ufw --force enable
    ufw status verbose
}

function main()
{
    local appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    checkRequireDistributor

    header 'INSTALLING UFW'

    checkRequireRootUser

    installDependencies
    install
    installCleanUp
}

main "${@}"
