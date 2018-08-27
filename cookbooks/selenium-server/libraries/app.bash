#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"

function installRole()
{
    local -r role="${1}"
    local -r serverConfigDataRole=("${@:2}")

    checkNonEmptyString "${role}" 'undefined role'

    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/${role}.bash"

    # Clean Up

    initializeFolder "${SELENIUM_SERVER_INSTALL_FOLDER_PATH}"

    # Install

    local -r jarFile="${SELENIUM_SERVER_INSTALL_FOLDER_PATH}/selenium-server.jar"

    downloadFile "${SELENIUM_SERVER_DOWNLOAD_URL}" "${jarFile}" 'true'

    # Config Server

    local -r configFile="${SELENIUM_SERVER_INSTALL_FOLDER_PATH}/selenium-server-${role}.json"

    createFileFromTemplate "$(dirname "${BASH_SOURCE[0]}")/../templates/selenium-server-${role}.json.conf" "${configFile}" "${serverConfigDataRole[@]}"

    # Config Init

    local -r initConfigData=(
        '__INSTALL_FILE__' "${jarFile}"
        '__CONFIG_FILE__' "${configFile}"
        '__USER_NAME__' "${SELENIUM_SERVER_USER_NAME}"
        '__GROUP_NAME__' "${SELENIUM_SERVER_GROUP_NAME}"
    )

    createInitFileFromTemplate "selenium-server-${role}" "$(dirname "${BASH_SOURCE[0]}")/../templates" "${initConfigData[@]}"

    # Start

    addUser "${SELENIUM_SERVER_USER_NAME}" "${SELENIUM_SERVER_GROUP_NAME}" 'false' 'true' 'false'
    chown -R "${SELENIUM_SERVER_USER_NAME}:${SELENIUM_SERVER_GROUP_NAME}" "${SELENIUM_SERVER_INSTALL_FOLDER_PATH}"
    startService "${SELENIUM_SERVER_SERVICE_NAME}"
}