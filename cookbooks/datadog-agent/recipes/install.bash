#!/bin/bash -e

function install()
{
    umask '0022'

    export DD_API_KEY="${DATADOG_AGENT_API_KEY}"
    curl -s -L "${DATADOG_AGENT_DOWNLOAD_URL}" --retry 12 --retry-delay 5 | bash -e
    restartService 'datadog-agent'

    umask '0077'
}

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    header 'INSTALLING DATADOG-AGENT'

    checkRequireLinuxSystem
    checkRequireRootUser

    install
    installCleanUp
}

main "${@}"