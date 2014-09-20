#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"


function install()
{
    local role="${1}"

    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/${role}.bash"

    # Clean Up

    initializeFolder "${seleniumserverInstallFolder}"

    # Install

    local jarFile="${seleniumserverInstallFolder}/selenium-server.jar"

    downloadFile "${seleniumserverDownloadURL}" "${jarFile}" 'true'

    # Config Server

    local configFile="${seleniumserverInstallFolder}/selenium-server-${role}.json"

    local serverConfigData=(
        '__PORT__' "${seleniumserverPort}"
    )

    createFileFromTemplate "${appPath}/../templates/default/selenium-server-${role}.json.conf" "${configFile}" "${serverConfigData[@]}"

    # Config Upstart

    local upstartConfigData=(
        '__INSTALL_FILE__' "${jarFile}"
        '__CONFIG_FILE__' "${configFile}"
        '__USER_NAME__' "${seleniumserverUserName}"
        '__GROUP_NAME__' "${seleniumserverGroupName}"
    )

    createFileFromTemplate "${appPath}/../templates/default/selenium-server-${role}.conf.upstart" "/etc/init/${seleniumserverServiceName}.conf" "${upstartConfigData[@]}"

    # Start

    addUser "${seleniumserverUserName}" "${seleniumserverGroupName}" 'false' 'true' 'false'
    chown -R "${seleniumserverUserName}:${seleniumserverGroupName}" "${seleniumserverInstallFolder}"
    start "${seleniumserverServiceName}"
}