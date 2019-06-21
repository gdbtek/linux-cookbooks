#!/bin/bash -e

function install()
{
    umask '0022'

    installPackages 'open-vm-tools'

    if [[ "$(isAmazonLinuxDistributor)" = 'true' || "$(isCentOSDistributor)" = 'true' || "$(isRedHatDistributor)" = 'true' ]]
    then
        restartService 'vmtoolsd'
    else
        restartService 'open-vm-tools'
    fi

    umask '0077'
}

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"

    header 'INSTALLING VMWARE-TOOLS'

    checkRequireLinuxSystem
    checkRequireRootUser

    install
    installCleanUp
}

main "${@}"