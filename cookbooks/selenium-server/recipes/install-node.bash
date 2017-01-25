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
    local -r hubHost="${1}"

    umask '0022'

    # Override Default

    if [[ "$(isEmptyString "${hubHost}")" = 'false' ]]
    then
        SELENIUM_SERVER_HUB_HOST="${hubHost}"
    fi

    checkNonEmptyString "${SELENIUM_SERVER_HUB_HOST}" 'undefined hub host'

    # Install Role

    local -r serverConfigData=(
        '__PORT__' "${SELENIUM_SERVER_PORT}"
        '__HUB_PORT__' "${SELENIUM_SERVER_HUB_PORT}"
        '__HUB_HOST__' "${SELENIUM_SERVER_HUB_HOST}"
    )

    installRole 'node' "${serverConfigData[@]}"

    # Display Open Ports

    displayOpenPorts '5'

    umask '0077'
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/node.bash"
    source "${APP_FOLDER_PATH}/../libraries/app.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING NODE SELENIUM-SERVER'

    checkRequirePorts "${SELENIUM_SERVER_PORT}"

    installDependencies
    install "${@}"
    installCleanUp
}

main "${@}"