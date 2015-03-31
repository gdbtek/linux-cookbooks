#!/bin/bash -e

function install()
{
    # Clean Up

    initializeFolder "${awscliInstallFolder}"

    # Install

    unzipRemoteFile "${awscliDownloadURL}" "${awscliInstallFolder}"

    info "\n$(aws --version 2>&1)"
}

function main()
{
    local appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING AWS-CLI'

    install
    installCleanUp
}

main "${@}"