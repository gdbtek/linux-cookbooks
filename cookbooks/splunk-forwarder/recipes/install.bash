#!/bin/bash -e

function install()
{
    umask '0022'

    # Clean Up

    initializeFolder "${SPLUNK_FORWARDER_INSTALL_FOLDER_PATH}"

    # Install

    unzipRemoteFile "${SPLUNK_FORWARDER_DOWNLOAD_URL}" "${SPLUNK_FORWARDER_INSTALL_FOLDER_PATH}"

    # Config Init

    if [[ "$(existCommand 'systemctl')" = 'true' ]]
    then
        local -r initConfigData=(
            '__GROUP_NAME__' "${SPLUNK_FORWARDER_GROUP_NAME}"
            '__INSTALL_FOLDER_PATH__' "${SPLUNK_FORWARDER_INSTALL_FOLDER_PATH}"
            '__USER_NAME__' "${SPLUNK_FORWARDER_USER_NAME}"
        )

        createInitFileFromTemplate "${SPLUNK_FORWARDER_SERVICE_NAME}" "$(dirname "${BASH_SOURCE[0]}")/../templates" "${initConfigData[@]}"
    else
        "${SPLUNK_FORWARDER_INSTALL_FOLDER_PATH}/bin/splunk" enable boot-start --accept-license --answer-yes --no-prompt
    fi

    # Config Profile

    createFileFromTemplate \
        "$(dirname "${BASH_SOURCE[0]}")/../templates/splunk.sh.profile" \
        '/etc/profile.d/splunk.sh' \
        '__INSTALL_FOLDER_PATH__' \
        "${SPLUNK_FORWARDER_INSTALL_FOLDER_PATH}"

    # Enable (Not Start Yet)

    addUser "${SPLUNK_FORWARDER_USER_NAME}" "${SPLUNK_FORWARDER_GROUP_NAME}" 'false' 'true' 'false'
    chown -R "${SPLUNK_FORWARDER_USER_NAME}:${SPLUNK_FORWARDER_GROUP_NAME}" "${SPLUNK_FORWARDER_INSTALL_FOLDER_PATH}"
    enableService "${SPLUNK_FORWARDER_SERVICE_NAME}"

    umask '0077'
}

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    header 'INSTALLING SPLUNK-FORWARDER'

    checkRequireLinuxSystem
    checkRequireRootUser
    checkRequirePorts '8089'

    install
    installCleanUp
}

main "${@}"