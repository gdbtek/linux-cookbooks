#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'java')" = 'false' || ! -d "${SELENIUM_SERVER_JDK_INSTALL_FOLDER}" ]]
    then
        "${appFolderPath}/../../jdk/recipes/install.bash" "${SELENIUM_SERVER_JDK_INSTALL_FOLDER}"
    fi
}

function install()
{
    local -r hubHost="${1}"

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
}

function main()
{
    appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../../../libraries/util.bash"
    source "${appFolderPath}/../attributes/node.bash"
    source "${appFolderPath}/../libraries/util.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING NODE SELENIUM-SERVER'

    checkRequirePort "${SELENIUM_SERVER_PORT}"

    installDependencies
    install "${@}"
    installCleanUp
}

main "${@}"