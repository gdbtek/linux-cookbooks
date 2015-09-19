#!/bin/bash -e

function install()
{
    # Clean Up

    jenkinsMasterWARAppCleanUp

    # Install

    jenkinsMasterDownloadWARApp
    jenkinsMasterDisplayVersion
    jenkinsMasterRefreshUpdateCenter
    jenkinsMasterUpdatePlugins
    jenkinsMasterSafeRestart
}

function main()
{
    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # shellcheck source=/dev/null
    source "${appPath}/../../../libraries/util.bash"
    # shellcheck source=/dev/null
    source "${appPath}/../libraries/util.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'UPGRADING MASTER JENKINS'

    install
    installCleanUp
}

main "${@}"