#!/bin/bash -e

function install()
{
    umask '0022'

    # Clean Up

    initializeFolder "${SPLUNK_FORWARDER_INSTALL_FOLDER_PATH}"

    # Install

    unzipRemoteFile "${SPLUNK_FORWARDER_DOWNLOAD_URL}" "${SPLUNK_FORWARDER_INSTALL_FOLDER_PATH}"

    # Config Init

    local -r initConfigData=(
        '__GROUP_NAME__' "${SPLUNK_FORWARDER_GROUP_NAME}"
        '__INSTALL_FOLDER_PATH__' "${SPLUNK_FORWARDER_INSTALL_FOLDER_PATH}"
        '__USER_NAME__' "${SPLUNK_FORWARDER_USER_NAME}"
    )

    createInitFileFromTemplate "${SPLUNK_FORWARDER_SERVICE_NAME}" "${APP_FOLDER_PATH}/../templates" "${initConfigData[@]}"

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER_PATH__' "${SPLUNK_FORWARDER_INSTALL_FOLDER_PATH}")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/splunk-forwarder.sh.profile" '/etc/profile.d/splunk-forwarder.sh' "${profileConfigData[@]}"

    # Enable (Not Start Yet) and Status

    chown -R "${SPLUNK_FORWARDER_USER_NAME}:${SPLUNK_FORWARDER_GROUP_NAME}" "${SPLUNK_FORWARDER_INSTALL_FOLDER_PATH}"
    enableStatusService "${SPLUNK_FORWARDER_SERVICE_NAME}"

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

    header 'INSTALLING SPLUNK-FORWARDER'

    checkRequirePorts '8089'

    install
    installCleanUp
}

main "${@}"