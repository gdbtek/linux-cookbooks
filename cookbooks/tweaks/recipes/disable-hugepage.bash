#!/bin/bash -e

function install()
{
    umask '0022'

    createInitFileFromTemplate "${HUGEPAGE_SERVICE_NAME}" "${APP_FOLDER_PATH}/../templates"
    startService "${HUGEPAGE_SERVICE_NAME}"

    umask '0077'
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/hugepage.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'DISABLING HUGEPAGE'

    install
    installCleanUp
}

main "${@}"