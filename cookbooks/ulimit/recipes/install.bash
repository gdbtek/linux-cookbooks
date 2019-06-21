#!/bin/bash -e

function install()
{
    umask '0022'

    cp -f "$(dirname "${BASH_SOURCE[0]}")/../files/limits.conf" '/etc/security/limits.conf'
    displayVersion "$(cat '/etc/security/limits.conf')"

    umask '0077'
}

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"

    header 'INSTALLING ULIMIT'

    checkRequireLinuxSystem
    checkRequireRootUser

    install
    installCleanUp
}

main "${@}"