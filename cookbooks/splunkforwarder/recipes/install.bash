#!/bin/bash -e

function install()
{
    umask '0022'

    # Clean Up

    initializeFolder "${SPLUNKFORWARDER_INSTALL_FOLDER_PATH}"

    # Install

    unzipRemoteFile "${SPLUNKFORWARDER_DOWNLOAD_URL}" "${SPLUNKFORWARDER_INSTALL_FOLDER_PATH}"

    # Config Init

    if [[ "$(existCommand 'systemctl')" = 'true' ]]
    then
        local -r initConfigData=(
            '__GROUP_NAME__' "${SPLUNKFORWARDER_GROUP_NAME}"
            '__INSTALL_FOLDER_PATH__' "${SPLUNKFORWARDER_INSTALL_FOLDER_PATH}"
            '__USER_NAME__' "${SPLUNKFORWARDER_USER_NAME}"
        )

        createInitFileFromTemplate "${SPLUNKFORWARDER_SERVICE_NAME}" "${APP_FOLDER_PATH}/../templates" "${initConfigData[@]}"
    else
        "${SPLUNKFORWARDER_INSTALL_FOLDER_PATH}/bin/splunk" enable boot-start --accept-license --answer-yes --no-prompt
    fi

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER_PATH__' "${SPLUNKFORWARDER_INSTALL_FOLDER_PATH}")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/splunk.sh.profile" '/etc/profile.d/splunk.sh' "${profileConfigData[@]}"

    # Enable (Not Start Yet) and Status

    addUser "${SPLUNKFORWARDER_USER_NAME}" "${SPLUNKFORWARDER_GROUP_NAME}" 'false' 'true' 'false'
    chown -R "${SPLUNKFORWARDER_USER_NAME}:${SPLUNKFORWARDER_GROUP_NAME}" "${SPLUNKFORWARDER_INSTALL_FOLDER_PATH}"
    enableService "${SPLUNKFORWARDER_SERVICE_NAME}"

    umask '0077'
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING SPLUNKFORWARDER'

    checkRequirePorts '8089'

    install
    installCleanUp
}

main "${@}"