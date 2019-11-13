#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'java')" = 'false' ]]
    then
        "$(dirname "${BASH_SOURCE[0]}")/../../jdk/recipes/install.bash"
    fi
}

function install()
{
    umask '0022'

    # Clean Up

    initializeFolder "${WILDFLY_INSTALL_FOLDER_PATH}"

    # Install

    unzipRemoteFile "${WILDFLY_DOWNLOAD_URL}" "${WILDFLY_INSTALL_FOLDER_PATH}"

    # Config Init

    local -r initConfigData=(
        '__APPLICATION_BIND_ADDRESS__' "${WILDFLY_APPLICATION_BIND_ADDRESS}"
        '__GROUP_NAME__' "${WILDFLY_GROUP_NAME}"
        '__INSTALL_FOLDER_PATH__' "${WILDFLY_INSTALL_FOLDER_PATH}"
        '__MANAGEMENT_BIND_ADDRESS__' "${WILDFLY_MANAGEMENT_BIND_ADDRESS}"
        '__USER_NAME__' "${WILDFLY_USER_NAME}"
    )

    createInitFileFromTemplate "${WILDFLY_SERVICE_NAME}" "$(dirname "${BASH_SOURCE[0]}")/../templates" "${initConfigData[@]}"

    # Add Management User

    "${WILDFLY_INSTALL_FOLDER_PATH}/bin/add-user.sh" --user "${WILDFLY_MANAGEMENT_USER}" --password "${WILDFLY_MANAGEMENT_PASSWORD}"

    # Start

    addUser "${WILDFLY_USER_NAME}" "${WILDFLY_GROUP_NAME}" 'false' 'true' 'false'
    chown -R "${WILDFLY_USER_NAME}:${WILDFLY_GROUP_NAME}" "${WILDFLY_INSTALL_FOLDER_PATH}"
    startService "${WILDFLY_SERVICE_NAME}"

    # Display Open Ports

    displayOpenPorts '5'

    umask '0077'
}

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    header 'INSTALLING WILDFLY'

    checkRequireLinuxSystem
    checkRequireRootUser
    checkRequirePorts '8080' '9990'

    installDependencies
    install
    installCleanUp
}

main "${@}"