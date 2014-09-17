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
    local appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../libraries/util.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'UPGRADING MASTER JENKINS'

    install
    installCleanUp
}

main "${@}"