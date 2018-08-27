#!/bin/bash -e

function install()
{
    umask '0022'

    # Clean Up

    initializeFolder "${KIBANA_INSTALL_FOLDER_PATH}"

    # Install

    unzipRemoteFile "${KIBANA_DOWNLOAD_URL}" "${KIBANA_INSTALL_FOLDER_PATH}"

    # Config Server

    local -r serverConfigData=(
        'http://localhost:9200' "${KIBANA_ELASTIC_SEARCH_URL}"
    )

    createFileFromTemplate "${KIBANA_INSTALL_FOLDER_PATH}/config/kibana.yml" "${KIBANA_INSTALL_FOLDER_PATH}/config/kibana.yml" "${serverConfigData[@]}"

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER_PATH__' "${KIBANA_INSTALL_FOLDER_PATH}")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/kibana.sh.profile" '/etc/profile.d/kibana.sh' "${profileConfigData[@]}"

    # Config Init

    local -r initConfigData=(
        '__INSTALL_FOLDER_PATH__' "${KIBANA_INSTALL_FOLDER_PATH}"
        '__USER_NAME__' "${KIBANA_USER_NAME}"
        '__GROUP_NAME__' "${KIBANA_GROUP_NAME}"
    )

    createInitFileFromTemplate "${KIBANA_SERVICE_NAME}" "${APP_FOLDER_PATH}/../templates" "${initConfigData[@]}"

    # Start

    addUser "${KIBANA_USER_NAME}" "${KIBANA_GROUP_NAME}" 'false' 'true' 'false'
    chown -R "${KIBANA_USER_NAME}:${KIBANA_GROUP_NAME}" "${KIBANA_INSTALL_FOLDER_PATH}"
    startService "${KIBANA_SERVICE_NAME}"

    # Display Open Ports

    displayOpenPorts '5'

    umask '0077'
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING KIBANA'

    install
    installCleanUp
}

main "${@}"