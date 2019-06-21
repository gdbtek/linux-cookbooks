#!/bin/bash -e

function install()
{
    umask '0022'

    cp -f "$(dirname "${BASH_SOURCE[0]}")/../files/limits.conf" "${ULIMIT_INSTALL_FILE_PATH}"
    displayVersion "$(cat "${ULIMIT_INSTALL_FILE_PATH}")"

    umask '0077'
}

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    header 'INSTALLING ULIMIT'

    checkRequireLinuxSystem
    checkRequireRootUser

    install
    installCleanUp
}

main "${@}"