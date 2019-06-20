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
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'UPGRADING MASTER JENKINS'

    install
    installCleanUp
}

main "${@}"