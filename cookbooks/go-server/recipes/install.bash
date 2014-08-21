#!/bin/bash -e

function install()
{
    "${appPath}/install-server.bash"
    "${appPath}/install-agent.bash" "${@}"
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    install "${@}"
    installCleanUp
}

main "${@}"