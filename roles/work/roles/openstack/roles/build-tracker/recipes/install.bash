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

    initializeFolder "${OPENSTACK_BUILD_TRACKER_INSTALL_FOLDER}"

    # Add User

    addUser "${OPENSTACK_BUILD_TRACKER_USER_NAME}" "${OPENSTACK_BUILD_TRACKER_GROUP_NAME}" 'false' 'true' 'false'

    # Install

    git clone "${buildTrackerDownloadURL}" "${OPENSTACK_BUILD_TRACKER_INSTALL_FOLDER}"
    cd "${OPENSTACK_BUILD_TRACKER_INSTALL_FOLDER}"
    npm install

    # Config Init

    local initConfigData=(
        '__INSTALL_FOLDER__' "${OPENSTACK_BUILD_TRACKER_INSTALL_FOLDER}"
        '__USER_NAME__' "${OPENSTACK_BUILD_TRACKER_USER_NAME}"
        '__GROUP_NAME__' "${OPENSTACK_BUILD_TRACKER_GROUP_NAME}"
    )

    createInitFileFromTemplate "${OPENSTACK_BUILD_TRACKER_SERVICE_NAME}" "${appFolderPath}/../templates" "${initConfigData[@]}"

    # Start

    chown -R "${OPENSTACK_BUILD_TRACKER_USER_NAME}:${OPENSTACK_BUILD_TRACKER_GROUP_NAME}" "${OPENSTACK_BUILD_TRACKER_INSTALL_FOLDER}"
    startService "${OPENSTACK_BUILD_TRACKER_SERVICE_NAME}"
}

main "${@}"