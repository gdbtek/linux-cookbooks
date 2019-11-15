#!/bin/bash -e

function install()
{
    umask '0022'

    if [[ "$(isUbuntuDistributor)" = 'true' ]]
    then
        installPackages 'ufw'

        # Set Up Policies

        ufw --force reset
        ufw default deny incoming
        ufw default allow outgoing

        local policy=''

        for policy in "${UFW_POLICIES[@]}"
        do
            local rule=(${policy})

            ufw "${rule[@]}"
        done

        # Enable Service

        ufw --force enable
        ufw status verbose
    else
        fatal 'FATAL : only support Ubuntu OS'
    fi

    umask '0077'
}

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    header 'INSTALLING UFW'

    checkRequireLinuxSystem
    checkRequireRootUser

    install
    installCleanUp
}

main "${@}"