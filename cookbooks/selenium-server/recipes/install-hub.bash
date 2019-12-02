#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'java')" = 'false' ]]
    then
        "$(dirname "${BASH_SOURCE[0]}")/../../jdk/recipes/install.bash"
    fi
}

function install()
{
    umask '0022'

    # Install

    installRole \
        'hub' \
        '__PORT__' "${SELENIUM_SERVER_PORT}"

    # Display Open Ports

    displayOpenPorts '5'

    umask '0077'
}

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/hub.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../libraries/app.bash"

    header 'INSTALLING HUB SELENIUM-SERVER'

    checkRequireLinuxSystem
    checkRequireRootUser
    checkRequirePorts "${SELENIUM_SERVER_PORT}"

    installDependencies
    install
    installCleanUp
}

main "${@}"