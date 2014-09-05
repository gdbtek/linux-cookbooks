#!/bin/bash -e

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
    local appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../lib/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING UFW'

    install
    installCleanUp
}

main "${@}"