#!/bin/bash -e

function install()
{
    "${APP_FOLDER_PATH}/install-server.bash"
    "${APP_FOLDER_PATH}/install-agent.bash"
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"

    checkRequireSystem
    checkRequireRootUser

    install
    installCleanUp
}

main "${@}"