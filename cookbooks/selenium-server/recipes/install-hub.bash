#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'java')" = 'false' || ! -d "${seleniumserverJDKInstallFolder}" ]]
    then
        "${appPath}/../../jdk/recipes/install.bash" "${seleniumserverJDKInstallFolder}"
    fi
}

function install()
{
    # Clean Up

    initializeFolder "${seleniumserverInstallFolder}"

    # Install

    local jarFile="${seleniumserverInstallFolder}/selenium-server.jar"

    downloadFile "${seleniumserverDownloadURL}" "${jarFile}" 'true'

    # Config Server

    local configFile="${seleniumserverInstallFolder}/selenium-server-hub.json"

    local serverConfigData=(
        '__PORT__' "${seleniumserverPort}"
    )

    createFileFromTemplate "${appPath}/../templates/default/selenium-server-hub.json.conf" "${configFile}" "${serverConfigData[@]}"

    # Config Upstart

    local upstartConfigData=(
        '__INSTALL_FILE__' "${jarFile}"
        '__CONFIG_FILE__' "${configFile}"
        '__USER_NAME__' "${seleniumserverUserName}"
        '__GROUP_NAME__' "${seleniumserverGroupName}"
    )

    createFileFromTemplate "${appPath}/../templates/default/selenium-hub.conf.upstart" "/etc/init/${seleniumserverServiceName}.conf" "${upstartConfigData[@]}"

    # Start

    addUser "${seleniumserverUserName}" "${seleniumserverGroupName}" 'false' 'true' 'false'
    chown -R "${seleniumserverUserName}:${seleniumserverGroupName}" "${seleniumserverInstallFolder}"
    start "${seleniumserverServiceName}"
}

function main()
{
    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/hub.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING SELENIUM-SERVER (HUB)'

    checkRequirePort "${seleniumserverPort}"

    installDependencies
    install
    installCleanUp

    displayOpenPorts
}

main "${@}"