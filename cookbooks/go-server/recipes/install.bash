#!/bin/bash -e

function install()
{
    "${appPath}/install-server.bash" || exit 1
    "${appPath}/install-agent.bash" "${@}" || exit 1
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    checkRequireSystem
    checkRequireRootUser

    install "${@}"
    installCleanUp
}

main "${@}"