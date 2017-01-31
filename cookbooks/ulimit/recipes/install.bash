#!/bin/bash -e

function install()
{
    umask '0022'

    cp -f "${APP_FOLDER_PATH}/../files/limits.conf" "${ULIMIT_INSTALL_FILE_PATH}"
    displayVersion "$(cat "${ULIMIT_INSTALL_FILE_PATH}")"

    umask '0077'
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING ULIMIT'

    install
    installCleanUp
}

main "${@}"