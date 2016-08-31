#!/bin/bash -e

function install()
{
    export DD_API_KEY="${DATA_DOG_API_KEY}"
    bash -c -e "$(curl -s -L "${DATA_DOG_DOWNLOAD_URL}" --retry 12 --retry-delay 5)"

    # Display Open Ports

    # displayOpenPorts '10'

    # Display Version

    # displayVersion "$("${ELASTIC_SEARCH_INSTALL_FOLDER}/bin/elasticsearch" --version)"
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING DATA-DOG'

    install
    installCleanUp
}

main "${@}"