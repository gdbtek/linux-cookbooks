#!/bin/bash -e

function install()
{
    umask '0022'

    installPackages 'open-vm-tools'

    umask '0077'
}

function main()
{
    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../../../libraries/util.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING VMWARE-TOOLS'

    install
    installCleanUp
}

main "${@}"