#!/bin/bash -e

function install()
{
    umask '0022'

    createInitFileFromTemplate "${HUGEPAGE_SERVICE_NAME}" "$(dirname "${BASH_SOURCE[0]}")/../templates"
    startService "${HUGEPAGE_SERVICE_NAME}"

    umask '0077'
}

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/hugepage.bash"

    header 'DISABLING HUGEPAGE'

    checkRequireLinuxSystem
    checkRequireRootUser

    install
    installCleanUp
}

main "${@}"