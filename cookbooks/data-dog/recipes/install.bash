#!/bin/bash -e

function install()
{
    umask '0022'

    # Install

    export DD_API_KEY="${DATA_DOG_API_KEY}"
    bash -c -e "$(curl -s -L "${DATA_DOG_DOWNLOAD_URL}" --retry 12 --retry-delay 5)"

    # Display Status

    service 'datadog-agent' info

    umask '0077'
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING DATA-DOG'

    install
    installCleanUp
}

main "${@}"