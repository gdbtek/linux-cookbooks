#!/bin/bash -e

function install()
{
    # Install

    installAptGetPackages 'shellcheck'

    # Display Version

    info "\n$(shellcheck -V)"
}

function main()
{
    local appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING SHELL-CHECK'

    install
    installCleanUp
}

main "${@}"