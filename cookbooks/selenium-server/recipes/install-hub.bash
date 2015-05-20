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
    local -r serverConfigData=(
        '__PORT__' "${SELENIUM_SERVER_PORT}"
    )

    installRole 'hub' "${serverConfigData[@]}"
}

function main()
{
    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/hub.bash"
    source "${appPath}/../libraries/util.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING HUB SELENIUM-SERVER'

    checkRequirePort "${SELENIUM_SERVER_PORT}"

    installDependencies
    install
    installCleanUp

    displayOpenPorts
}

main "${@}"