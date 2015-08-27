#!/bin/bash -e

function install()
{
    # Clean Up

    initializeFolder "${KIBANA_INSTALL_FOLDER}"

    # Install

    unzipRemoteFile "${KIBANA_DOWNLOAD_URL}" "${KIBANA_INSTALL_FOLDER}"

    # Config Server

    local -r serverConfigData=(
        'http://localhost:9200' "${KIBANA_ELASTIC_SEARCH_URL}"
    )

    createFileFromTemplate "${KIBANA_INSTALL_FOLDER}/config/kibana.yml" "${KIBANA_INSTALL_FOLDER}/config/kibana.yml" "${serverConfigData[@]}"

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER__' "${KIBANA_INSTALL_FOLDER}")

    createFileFromTemplate "${appPath}/../templates/default/kibana.sh.profile" '/etc/profile.d/kibana.sh' "${profileConfigData[@]}"

    # Config Upstart

    local -r upstartConfigData=(
        '__INSTALL_FOLDER__' "${KIBANA_INSTALL_FOLDER}"
        '__USER_NAME__' "${KIBANA_USER_NAME}"
        '__GROUP_NAME__' "${KIBANA_GROUP_NAME}"
    )

    createFileFromTemplate "${appPath}/../templates/default/kibana.conf.upstart" "/etc/init/${KIBANA_SERVICE_NAME}.conf" "${upstartConfigData[@]}"

    # Start

    addUser "${KIBANA_USER_NAME}" "${KIBANA_GROUP_NAME}" 'false' 'true' 'false'
    chown -R "${KIBANA_USER_NAME}:${KIBANA_GROUP_NAME}" "${KIBANA_INSTALL_FOLDER}"
    start "${KIBANA_SERVICE_NAME}"

    # Display Open Ports

    displayOpenPorts '5'
}

function main()
{
    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/default.bash"
    source "${appPath}/../../nginx/attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING KIBANA'

    install
    installCleanUp
}

main "${@}"