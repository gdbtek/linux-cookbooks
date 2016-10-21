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
    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../../../libraries/util.bash"
    source "${appFolderPath}/../attributes/default.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING UFW'

    install
    installCleanUp
}

main "${@}"