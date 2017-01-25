#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'java')" = 'false' || ! -d "${WILD_FLY_JDK_INSTALL_FOLDER_PATH}" ]]
    then
        "${APP_FOLDER_PATH}/../../jdk/recipes/install.bash" "${WILD_FLY_JDK_INSTALL_FOLDER_PATH}"
    fi
}

function install()
{
    umask '0022'

    # Clean Up

    initializeFolder "${WILD_FLY_INSTALL_FOLDER_PATH}"

    # Install

    unzipRemoteFile "${WILD_FLY_DOWNLOAD_URL}" "${WILD_FLY_INSTALL_FOLDER_PATH}"

    # Config Init

    local -r initConfigData=(
        '__APPLICATION_BIND_ADDRESS__' "${WILD_FLY_APPLICATION_BIND_ADDRESS}"
        '__GROUP_NAME__' "${WILD_FLY_GROUP_NAME}"
        '__INSTALL_FOLDER_PATH__' "${WILD_FLY_INSTALL_FOLDER_PATH}"
        '__MANAGEMENT_BIND_ADDRESS__' "${WILD_FLY_MANAGEMENT_BIND_ADDRESS}"
        '__USER_NAME__' "${WILD_FLY_USER_NAME}"
    )

    createInitFileFromTemplate "${WILD_FLY_SERVICE_NAME}" "${APP_FOLDER_PATH}/../templates" "${initConfigData[@]}"

    # Add Management User

    "${WILD_FLY_INSTALL_FOLDER_PATH}/bin/add-user.sh" --user "${WILD_FLY_MANAGEMENT_USER}" --password "${WILD_FLY_MANAGEMENT_PASSWORD}"

    # Start

    addUser "${WILD_FLY_USER_NAME}" "${WILD_FLY_GROUP_NAME}" 'false' 'true' 'false'
    chown -R "${WILD_FLY_USER_NAME}:${WILD_FLY_GROUP_NAME}" "${WILD_FLY_INSTALL_FOLDER_PATH}"
    startService "${WILD_FLY_SERVICE_NAME}"

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

    header 'INSTALLING WILD-FLY'

    checkRequirePorts '8080' '9990'

    installDependencies
    install
    installCleanUp
}

main "${@}"