#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"

function installRole()
{
    local -r role="${1}"
    local -r serverConfigData=("${@:2}")

    checkNonEmptyString "${role}" 'undefined role'

    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/${role}.bash"

    # Clean Up

    initializeFolder "${seleniumserverInstallFolder}"

    # Install

    local -r jarFile="${seleniumserverInstallFolder}/selenium-server.jar"

    downloadFile "${seleniumserverDownloadURL}" "${jarFile}" 'true'

    # Config Server

    local -r configFile="${seleniumserverInstallFolder}/selenium-server-${role}.json"

    createFileFromTemplate "$(dirname "${BASH_SOURCE[0]}")/../templates/default/selenium-server-${role}.json.conf" "${configFile}" "${serverConfigData[@]}"

    # Config Upstart

    local -r upstartConfigData=(
        '__INSTALL_FILE__' "${jarFile}"
        '__CONFIG_FILE__' "${configFile}"
        '__USER_NAME__' "${seleniumserverUserName}"
        '__GROUP_NAME__' "${seleniumserverGroupName}"
    )

    createFileFromTemplate "$(dirname "${BASH_SOURCE[0]}")/../templates/default/selenium-server-${role}.conf.upstart" "/etc/init/${seleniumserverServiceName}.conf" "${upstartConfigData[@]}"

    # Start

    addUser "${seleniumserverUserName}" "${seleniumserverGroupName}" 'false' 'true' 'false'
    chown -R "${seleniumserverUserName}:${seleniumserverGroupName}" "${seleniumserverInstallFolder}"
    start "${seleniumserverServiceName}"
}