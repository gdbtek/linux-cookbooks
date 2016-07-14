#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'java')" = 'false' || ! -d "${WILD_FLY_JDK_INSTALL_FOLDER}" ]]
    then
        "${APP_FOLDER_PATH}/../../jdk/recipes/install.bash" "${WILD_FLY_JDK_INSTALL_FOLDER}"
    fi
}

function install()
{
    # Clean Up

    initializeFolder "${WILD_FLY_INSTALL_FOLDER}"

    # Install

    unzipRemoteFile "${WILD_FLY_DOWNLOAD_URL}" "${WILD_FLY_INSTALL_FOLDER}"

    # Config Systemd

    local -r systemdConfigData=(
        '__APPLICATION_BIND_ADDRESS__' "${WILD_FLY_APPLICATION_BIND_ADDRESS}"
        '__GROUP_NAME__' "${WILD_FLY_GROUP_NAME}"
        '__INSTALL_FOLDER__' "${WILD_FLY_INSTALL_FOLDER}"
        '__MANAGEMENT_BIND_ADDRESS__' "${WILD_FLY_MANAGEMENT_BIND_ADDRESS}"
        '__USER_NAME__' "${WILD_FLY_USER_NAME}"
    )

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/wild-fly.conf.upstart" "/etc/init/${WILD_FLY_SERVICE_NAME}.conf" "${systemdConfigData[@]}"

    # Add Management User

    "${WILD_FLY_INSTALL_FOLDER}/bin/add-user.sh" --user "${WILD_FLY_MANAGEMENT_USER}" --password "${WILD_FLY_MANAGEMENT_PASSWORD}"

    # Start

    addUser "${WILD_FLY_USER_NAME}" "${WILD_FLY_GROUP_NAME}" 'false' 'true' 'false'
    chown -R "${WILD_FLY_USER_NAME}:${WILD_FLY_GROUP_NAME}" "${WILD_FLY_INSTALL_FOLDER}"
    start "${WILD_FLY_SERVICE_NAME}"

    # Display Open Ports

    displayOpenPorts '5'
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING WILD-FLY'

    checkRequirePort '8080' '9990'

    installDependencies
    install
    installCleanUp
}

main "${@}"