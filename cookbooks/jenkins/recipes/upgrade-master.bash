#!/bin/bash -e

function install()
{
    umask '0022'

    # Clean Up

    jenkinsMasterWARAppCleanUp

    # Install

    jenkinsMasterDownloadWARApp
    sleep 75
    jenkinsMasterDisplayVersion
    jenkinsMasterRefreshUpdateCenter
    jenkinsMasterUpdatePlugins
    jenkinsMasterSafeRestart

    umask '0077'
}

function main()
{
    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../../../libraries/util.bash"
    source "${appFolderPath}/../libraries/app.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'UPGRADING MASTER JENKINS'

    install
    installCleanUp
}

main "${@}"