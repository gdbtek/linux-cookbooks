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
        createInitFileFromTemplate \
            "${SPLUNKFORWARDER_SERVICE_NAME}" \
            "$(dirname "${BASH_SOURCE[0]}")/../templates" \
            '__GROUP_NAME__' "${SPLUNKFORWARDER_GROUP_NAME}" \
            '__INSTALL_FOLDER_PATH__' "${SPLUNKFORWARDER_INSTALL_FOLDER_PATH}" \
            '__USER_NAME__' "${SPLUNKFORWARDER_USER_NAME}"
    else
        "${SPLUNKFORWARDER_INSTALL_FOLDER_PATH}/bin/splunk" enable boot-start --accept-license --answer-yes --no-prompt
    fi

    # Config Profile

    createFileFromTemplate \
        "$(dirname "${BASH_SOURCE[0]}")/../templates/splunk.sh.profile" \
        '/etc/profile.d/splunk.sh' \
        '__INSTALL_FOLDER_PATH__' \
        "${SPLUNKFORWARDER_INSTALL_FOLDER_PATH}"

    # Enable (Not Start Yet)

    addUser "${SPLUNKFORWARDER_USER_NAME}" "${SPLUNKFORWARDER_GROUP_NAME}" 'false' 'true' 'false'
    chown -R "${SPLUNKFORWARDER_USER_NAME}:${SPLUNKFORWARDER_GROUP_NAME}" "${SPLUNKFORWARDER_INSTALL_FOLDER_PATH}"
    enableService "${SPLUNKFORWARDER_SERVICE_NAME}"

    umask '0077'
}

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    header 'INSTALLING SPLUNKFORWARDER'

    checkRequireLinuxSystem
    checkRequireRootUser
    checkRequirePorts '8089'

    install
    installCleanUp
}

main "${@}"