#!/bin/bash -e

function install()
{
    umask '0022'

    export DD_API_KEY="${DATA_DOG_API_KEY}"
    bash -c -e "$(curl -s -L "${DATA_DOG_DOWNLOAD_URL}" --retry 12 --retry-delay 5)"
    statusService 'datadog-agent'

    umask '0077'
}

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    header 'INSTALLING DATA-DOG'

    checkRequireLinuxSystem
    checkRequireRootUser

    install
    installCleanUp
}

main "${@}"