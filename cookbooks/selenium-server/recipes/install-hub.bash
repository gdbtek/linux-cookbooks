#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'java')" = 'false' || ! -d "${SELENIUM_SERVER_JDK_INSTALL_FOLDER}" ]]
    then
        "${appPath}/../../jdk/recipes/install.bash" "${SELENIUM_SERVER_JDK_INSTALL_FOLDER}"
    fi
}

function install()
{
    # Install

    local -r serverConfigData=(
        '__PORT__' "${SELENIUM_SERVER_PORT}"
    )

    installRole 'hub' "${serverConfigData[@]}"

    # Display Open Ports

    displayOpenPorts '5'
}

function main()
{
    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # shellcheck source=/dev/null
    source "${appPath}/../../../libraries/util.bash"
    # shellcheck source=/dev/null
    source "${appPath}/../attributes/hub.bash"
    # shellcheck source=/dev/null
    source "${appPath}/../libraries/util.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING HUB SELENIUM-SERVER'

    checkRequirePort "${SELENIUM_SERVER_PORT}"

    installDependencies
    install
    installCleanUp
}

main "${@}"