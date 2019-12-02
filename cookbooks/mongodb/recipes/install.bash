#!/bin/bash -e

function install()
{
    umask '0022'

    # Clean Up

    initializeFolder "${MONGODB_INSTALL_FOLDER_PATH}"
    initializeFolder "${MONGODB_INSTALL_DATA_FOLDER}"

    # Install

    unzipRemoteFile "${MONGODB_DOWNLOAD_URL}" "${MONGODB_INSTALL_FOLDER_PATH}"

    # Config Profile

    createFileFromTemplate \
        "$(dirname "${BASH_SOURCE[0]}")/../templates/mongodb.sh.profile" \
        '/etc/profile.d/mongodb.sh' \
        '__INSTALL_FOLDER_PATH__' "${MONGODB_INSTALL_FOLDER_PATH}"

    # Config Init

    createInitFileFromTemplate \
        "${MONGODB_SERVICE_NAME}" \
        "$(dirname "${BASH_SOURCE[0]}")/../templates" \
        '__INSTALL_FOLDER_PATH__' "${MONGODB_INSTALL_FOLDER_PATH}" \
        '__INSTALL_DATA_FOLDER__' "${MONGODB_INSTALL_DATA_FOLDER}" \
        '__USER_NAME__' "${MONGODB_USER_NAME}" \
        '__GROUP_NAME__' "${MONGODB_GROUP_NAME}" \
        '__PORT__' "${MONGODB_PORT}"

    chown -R "$(whoami):$(whoami)" "${MONGODB_INSTALL_FOLDER_PATH}"

    # Start

    addUser "${MONGODB_USER_NAME}" "${MONGODB_GROUP_NAME}" 'false' 'true' 'false'
    chown -R "${MONGODB_USER_NAME}:${MONGODB_GROUP_NAME}" "${MONGODB_INSTALL_FOLDER_PATH}"
    startService "${MONGODB_SERVICE_NAME}"

    # Display Open Ports

    displayOpenPorts '5'

    # Display Version

    displayVersion "$(mongo --version)"

    umask '0077'
}

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    header 'INSTALLING MONGODB'

    checkRequireLinuxSystem
    checkRequireRootUser
    checkRequirePorts "${MONGODB_PORT}"

    install
    installCleanUp
}

main "${@}"