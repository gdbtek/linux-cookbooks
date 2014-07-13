#!/bin/bash

function installDependencies()
{
    runAptGetUpdate
}

function install()
{
    installAptGetPackages 'ufw'

    # Set Up Policies

    ufw --force reset
    ufw default deny incoming
    ufw default allow outgoing

    local policy=''

    for policy in "${ufwPolicies[@]}"
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