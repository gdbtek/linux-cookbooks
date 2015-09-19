#!/bin/bash -e

function install()
{
    "${appPath}/install-server.bash"
    "${appPath}/install-agent.bash"
}

function main()
{
    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # shellcheck source=/dev/null
    source "${appPath}/../../../libraries/util.bash"

    checkRequireSystem
    checkRequireRootUser

    install
    installCleanUp
}

main "${@}"