#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'java')" = 'false' || ! -d "${SECRET_SERVER_CONSOLE_JDK_INSTALL_FOLDER_PATH}" ]]
    then
        "${APP_FOLDER_PATH}/../../jdk/recipes/install.bash" "${SECRET_SERVER_CONSOLE_JDK_INSTALL_FOLDER_PATH}"
    fi
}

function install()
{
    umask '0022'

    # Clean Up

    initializeFolder "${SECRET_SERVER_CONSOLE_INSTALL_FOLDER_PATH}"

    # Install

    local -r consoleJARFilePath="${SECRET_SERVER_CONSOLE_INSTALL_FOLDER_PATH}/$(basename "${SECRET_SERVER_CONSOLE_DOWNLOAD_URL}")"

    downloadFile "${SECRET_SERVER_CONSOLE_DOWNLOAD_URL}" "${consoleJARFilePath}" 'true'
    chown -R "$(whoami):$(whoami)" "${SECRET_SERVER_CONSOLE_INSTALL_FOLDER_PATH}"

    # Display Version

    displayVersion "$(java -jar "${consoleJARFilePath}" -version)"

    umask '0077'
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING SECRET SERVER CONSOLE'

    installDependencies
    install
    installCleanUp
}

main "${@}"