#!/bin/bash -e

function install()
{
    "${appFolderPath}/install-server.bash"
    "${appFolderPath}/install-agent.bash"
}

function main()
{
    appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../../../libraries/util.bash"

    checkRequireSystem
    checkRequireRootUser

    install
    installCleanUp
}

main "${@}"