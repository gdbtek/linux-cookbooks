#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'java')" = 'false' || ! -d "${TOMCAT_JDK_INSTALL_FOLDER_PATH}" ]]
    then
        "${APP_FOLDER_PATH}/../../jdk/recipes/install.bash" "${TOMCAT_JDK_INSTALL_FOLDER_PATH}"
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

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER_PATH__' "${TOMCAT_INSTALL_FOLDER_PATH}")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/tomcat.sh.profile" '/etc/profile.d/tomcat.sh' "${profileConfigData[@]}"

    # Add User

    addUser "${TOMCAT_USER_NAME}" "${TOMCAT_GROUP_NAME}" 'true' 'true' 'true'

    local -r userHome="$(getUserHomeFolder "${TOMCAT_USER_NAME}")"

    checkExistFolder "${userHome}"

    # Config Init

    local -r initConfigData=(
        '__INSTALL_FOLDER_PATH__' "${TOMCAT_INSTALL_FOLDER_PATH}"
        '__HOME_FOLDER__' "${userHome}"
        '__JDK_INSTALL_FOLDER_PATH__' "${TOMCAT_JDK_INSTALL_FOLDER_PATH}"
        '__USER_NAME__' "${TOMCAT_USER_NAME}"
        '__GROUP_NAME__' "${TOMCAT_GROUP_NAME}"
    )

    createInitFileFromTemplate "${TOMCAT_SERVICE_NAME}" "${APP_FOLDER_PATH}/../templates" "${initConfigData[@]}"

    # Config Cron

    local -r cronConfigData=(
        '__USER_NAME__' "${TOMCAT_USER_NAME}"
        '__GROUP_NAME__' "${TOMCAT_GROUP_NAME}"
        '__INSTALL_FOLDER_PATH__' "${TOMCAT_INSTALL_FOLDER_PATH}"
    )

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/tomcat.cron" '/etc/cron.daily/tomcat' "${cronConfigData[@]}"
    chmod 755 '/etc/cron.daily/tomcat'

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
    local -r installFolder="${1}"

    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING TOMCAT'

    # Override Default Config

    if [[ "$(isEmptyString "${installFolder}")" = 'false' ]]
    then
        TOMCAT_INSTALL_FOLDER_PATH="${installFolder}"
    fi

    # Install

    checkRequirePorts "${TOMCAT_AJP_PORT}" "${TOMCAT_COMMAND_PORT}" "${TOMCAT_HTTP_PORT}" "${TOMCAT_HTTPS_PORT}"

    installDependencies
    install
    installCleanUp
}

main "${@}"