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

    initializeFolder "${TOMCAT_INSTALL_FOLDER_PATH}"

    # Install

    unzipRemoteFile "${TOMCAT_DOWNLOAD_URL}" "${TOMCAT_INSTALL_FOLDER_PATH}"

    # Config Server

    local -r serverConfigData=(
        8009 "${TOMCAT_AJP_PORT}"
        8005 "${TOMCAT_COMMAND_PORT}"
        8080 "${TOMCAT_HTTP_PORT}"
        8443 "${TOMCAT_HTTPS_PORT}"
    )

    createFileFromTemplate "${TOMCAT_INSTALL_FOLDER_PATH}/conf/server.xml" "${TOMCAT_INSTALL_FOLDER_PATH}/conf/server.xml" "${serverConfigData[@]}"

    # Add User

    addUser "${TOMCAT_USER_NAME}" "${TOMCAT_GROUP_NAME}" 'true' 'true' 'true'

    # Config Init

    local -r initConfigData=(
        '__INSTALL_FOLDER_PATH__' "${TOMCAT_INSTALL_FOLDER_PATH}"
        '__JDK_INSTALL_FOLDER_PATH__' "${TOMCAT_JDK_INSTALL_FOLDER_PATH}"
        '__USER_NAME__' "${TOMCAT_USER_NAME}"
        '__GROUP_NAME__' "${TOMCAT_GROUP_NAME}"
    )

    createInitFileFromTemplate "${TOMCAT_SERVICE_NAME}" "$(dirname "${BASH_SOURCE[0]}")/../templates" "${initConfigData[@]}"

    # Start

    chown -R "${TOMCAT_USER_NAME}:${TOMCAT_GROUP_NAME}" "${TOMCAT_INSTALL_FOLDER_PATH}"
    startService "${TOMCAT_SERVICE_NAME}"

    # Display Open Ports

    displayOpenPorts '8'

    # Display Version

    displayVersion "$("${TOMCAT_INSTALL_FOLDER_PATH}/bin/version.sh")"

    umask '0077'
}

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    header 'INSTALLING TOMCAT'

    checkRequireLinuxSystem
    checkRequireRootUser
    checkRequirePorts "${TOMCAT_AJP_PORT}" "${TOMCAT_COMMAND_PORT}" "${TOMCAT_HTTP_PORT}" "${TOMCAT_HTTPS_PORT}"

    installDependencies
    install
    installCleanUp
}

main "${@}"