#!/bin/bash -e

function install()
{
    umask '0022'

    installPackages 'open-vm-tools'

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