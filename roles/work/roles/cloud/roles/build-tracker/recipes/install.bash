#!/bin/bash -e

function main()
{
    local -r buildTrackerDownloadURL="${1}"

    # Load Libraries

    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../../../../../../../libraries/util.bash"
    source "${appFolderPath}/../attributes/default.bash"

    # Install App

    header 'INSTALLING BUILD-TRACKER'

    # Clean Up

    remountTMP
    initializeFolder "${CLOUD_BUILD_TRACKER_INSTALL_FOLDER}"

    # Add User

    addUser "${CLOUD_BUILD_TRACKER_USER_NAME}" "${CLOUD_BUILD_TRACKER_GROUP_NAME}" 'false' 'true' 'false'

    # Install

    git clone "${buildTrackerDownloadURL}" "${CLOUD_BUILD_TRACKER_INSTALL_FOLDER}"
    cd "${CLOUD_BUILD_TRACKER_INSTALL_FOLDER}"
    npm install

    # Config Init

    local initConfigData=(
        '__INSTALL_FOLDER__' "${CLOUD_BUILD_TRACKER_INSTALL_FOLDER}"
        '__USER_NAME__' "${CLOUD_BUILD_TRACKER_USER_NAME}"
        '__GROUP_NAME__' "${CLOUD_BUILD_TRACKER_GROUP_NAME}"
    )

    createInitFileFromTemplate "${CLOUD_BUILD_TRACKER_SERVICE_NAME}" "${appFolderPath}/../templates" "${initConfigData[@]}"

    # Start

    chown -R "${CLOUD_BUILD_TRACKER_USER_NAME}:${CLOUD_BUILD_TRACKER_GROUP_NAME}" "${CLOUD_BUILD_TRACKER_INSTALL_FOLDER}"
    startService "${CLOUD_BUILD_TRACKER_SERVICE_NAME}"
}

main "${@}"