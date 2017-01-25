#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'java')" = 'false' || ! -d "${SELENIUM_SERVER_JDK_INSTALL_FOLDER_PATH}" ]]
    then
        "${APP_FOLDER_PATH}/../../jdk/recipes/install.bash" "${SELENIUM_SERVER_JDK_INSTALL_FOLDER_PATH}"
    fi
}

function install()
{
    umask '0022'

    # Install

    local -r serverConfigData=(
        '__PORT__' "${SELENIUM_SERVER_PORT}"
    )

    installRole 'hub' "${serverConfigData[@]}"

    # Display Open Ports

    displayOpenPorts '5'

    umask '0077'
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/hub.bash"
    source "${APP_FOLDER_PATH}/../libraries/app.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING HUB SELENIUM-SERVER'

    checkRequirePorts "${SELENIUM_SERVER_PORT}"

    installDependencies
    install
    installCleanUp
}

main "${@}"