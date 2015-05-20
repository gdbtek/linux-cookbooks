#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"

function installRole()
{
    local -r role="${1}"
    local -r serverConfigData=("${@:2}")

    checkNonEmptyString "${role}" 'undefined role'

    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/${role}.bash"

    # Clean Up

    initializeFolder "${SELENIUM_SERVER_INSTALL_FOLDER}"

    # Install

    local -r jarFile="${SELENIUM_SERVER_INSTALL_FOLDER}/selenium-server.jar"

    downloadFile "${SELENIUM_SERVER_DOWNLOAD_URL}" "${jarFile}" 'true'

    # Config Server

    local -r configFile="${SELENIUM_SERVER_INSTALL_FOLDER}/selenium-server-${role}.json"

    createFileFromTemplate "$(dirname "${BASH_SOURCE[0]}")/../templates/default/selenium-server-${role}.json.conf" "${configFile}" "${serverConfigData[@]}"

    # Config Upstart

    local -r upstartConfigData=(
        '__INSTALL_FILE__' "${jarFile}"
        '__CONFIG_FILE__' "${configFile}"
        '__USER_NAME__' "${SELENIUM_SERVER_USER_NAME}"
        '__GROUP_NAME__' "${SELENIUM_SERVER_GROUP_NAME}"
    )

    createFileFromTemplate "$(dirname "${BASH_SOURCE[0]}")/../templates/default/selenium-server-${role}.conf.upstart" "/etc/init/${SELENIUM_SERVER_SERVICE_NAME}.conf" "${upstartConfigData[@]}"

    # Start

    addUser "${SELENIUM_SERVER_USER_NAME}" "${SELENIUM_SERVER_GROUP_NAME}" 'false' 'true' 'false'
    chown -R "${SELENIUM_SERVER_USER_NAME}:${SELENIUM_SERVER_GROUP_NAME}" "${SELENIUM_SERVER_INSTALL_FOLDER}"
    start "${SELENIUM_SERVER_SERVICE_NAME}"
}