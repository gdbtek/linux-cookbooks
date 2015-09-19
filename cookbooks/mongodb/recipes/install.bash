#!/bin/bash -e

function install()
{
    # Clean Up

    initializeFolder "${MONGODB_INSTALL_FOLDER}"
    initializeFolder "${MONGODB_INSTALL_DATA_FOLDER}"

    # Install

    unzipRemoteFile "${MONGODB_DOWNLOAD_URL}" "${MONGODB_INSTALL_FOLDER}"
    find "${MONGODB_INSTALL_FOLDER}" -maxdepth 1 -type f -delete

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER__' "${MONGODB_INSTALL_FOLDER}")

    createFileFromTemplate "${appPath}/../templates/mongodb.sh.profile" '/etc/profile.d/mongodb.sh' "${profileConfigData[@]}"

    # Config Upstart

    local -r upstartConfigData=(
        '__INSTALL_FOLDER__' "${MONGODB_INSTALL_FOLDER}"
        '__INSTALL_DATA_FOLDER__' "${MONGODB_INSTALL_DATA_FOLDER}"
        '__USER_NAME__' "${MONGODB_USER_NAME}"
        '__GROUP_NAME__' "${MONGODB_GROUP_NAME}"
        '__PORT__' "${MONGODB_PORT}"
    )

    createFileFromTemplate "${appPath}/../templates/mongodb.conf.upstart" "/etc/init/${MONGODB_SERVICE_NAME}.conf" "${upstartConfigData[@]}"
    chown -R "$(whoami):$(whoami)" "${MONGODB_INSTALL_FOLDER}"

    # Start

    addUser "${MONGODB_USER_NAME}" "${MONGODB_GROUP_NAME}" 'false' 'true' 'false'
    chown -R "${MONGODB_USER_NAME}:${MONGODB_GROUP_NAME}" "${MONGODB_INSTALL_FOLDER}"
    start "${MONGODB_SERVICE_NAME}"

    # Display Open Ports

    displayOpenPorts '5'

    # Display Version

    info "\n$("${MONGODB_INSTALL_FOLDER}/bin/mongo" --version)"
}

function main()
{
    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # shellcheck source=/dev/null
    source "${appPath}/../../../libraries/util.bash"
    # shellcheck source=/dev/null
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING MONGODB'

    checkRequirePort "${MONGODB_PORT}"

    install
    installCleanUp
}

main "${@}"