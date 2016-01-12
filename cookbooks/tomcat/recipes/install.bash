#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'java')" = 'false' || ! -d "${TOMCAT_JDK_INSTALL_FOLDER}" ]]
    then
        "${APP_FOLDER_PATH}/../../jdk/recipes/install.bash" "${TOMCAT_JDK_INSTALL_FOLDER}"
    fi
}

function install()
{
    # Clean Up

    initializeFolder "${TOMCAT_INSTALL_FOLDER}"

    # Install

    unzipRemoteFile "${TOMCAT_DOWNLOAD_URL}" "${TOMCAT_INSTALL_FOLDER}"

    # Config Server

    local -r serverConfigData=(
        8009 "${TOMCAT_AJP_PORT}"
        8005 "${TOMCAT_COMMAND_PORT}"
        8080 "${TOMCAT_HTTP_PORT}"
        8443 "${TOMCAT_HTTPS_PORT}"
    )

    createFileFromTemplate "${TOMCAT_INSTALL_FOLDER}/conf/server.xml" "${TOMCAT_INSTALL_FOLDER}/conf/server.xml" "${serverConfigData[@]}"

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER__' "${TOMCAT_INSTALL_FOLDER}")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/tomcat.sh.profile" '/etc/profile.d/tomcat.sh' "${profileConfigData[@]}"

    # Add User

    addUser "${TOMCAT_USER_NAME}" "${TOMCAT_GROUP_NAME}" 'true' 'true' 'true'

    local -r userHome="$(getUserHomeFolder "${TOMCAT_USER_NAME}")"

    checkExistFolder "${userHome}"

    # Config Upstart

    local -r upstartConfigData=(
        '__INSTALL_FOLDER__' "${TOMCAT_INSTALL_FOLDER}"
        '__HOME_FOLDER__' "${userHome}"
        '__JDK_INSTALL_FOLDER__' "${TOMCAT_JDK_INSTALL_FOLDER}"
        '__USER_NAME__' "${TOMCAT_USER_NAME}"
        '__GROUP_NAME__' "${TOMCAT_GROUP_NAME}"
    )

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/tomcat.conf.upstart" "/etc/init/${TOMCAT_SERVICE_NAME}.conf" "${upstartConfigData[@]}"

    # Config Cron

    local -r cronConfigData=(
        '__USER_NAME__' "${TOMCAT_USER_NAME}"
        '__GROUP_NAME__' "${TOMCAT_GROUP_NAME}"
        '__INSTALL_FOLDER__' "${TOMCAT_INSTALL_FOLDER}"
    )

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/tomcat.cron" '/etc/cron.daily/tomcat' "${cronConfigData[@]}"
    chmod 755 '/etc/cron.daily/tomcat'

    # Start

    chown -R "${TOMCAT_USER_NAME}:${TOMCAT_GROUP_NAME}" "${TOMCAT_INSTALL_FOLDER}"
    start "${TOMCAT_SERVICE_NAME}"

    # Display Open Ports

    displayOpenPorts '5'

    # Display Version

    info "\n$("${TOMCAT_INSTALL_FOLDER}/bin/version.sh")"
}

function main()
{
    local -r installFolder="${1}"

    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING TOMCAT'

    # Override Default Config

    if [[ "$(isEmptyString "${installFolder}")" = 'false' ]]
    then
        TOMCAT_INSTALL_FOLDER="${installFolder}"
    fi

    # Install

    checkRequirePort "${TOMCAT_AJP_PORT}" "${TOMCAT_COMMAND_PORT}" "${TOMCAT_HTTP_PORT}" "${TOMCAT_HTTPS_PORT}"

    installDependencies
    install
    installCleanUp
}

main "${@}"