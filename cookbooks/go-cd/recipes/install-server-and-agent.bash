#!/bin/bash -e

function install()
{
    umask '0022'

    "${APP_FOLDER_PATH}/install-server.bash"
    "${APP_FOLDER_PATH}/install-agent.bash"

    umask '0077'
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    install
    installCleanUp
}

main "${@}"