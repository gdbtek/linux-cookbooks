#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'java')" = 'false' || ! -d "${SECRET_SERVER_CONSOLE_JDK_INSTALL_FOLDER}" ]]
    then
        "${APP_FOLDER_PATH}/../../jdk/recipes/install.bash" "${SECRET_SERVER_CONSOLE_JDK_INSTALL_FOLDER}"
    fi
}

function install()
{
    # Clean Up

    initializeFolder "${SECRET_SERVER_CONSOLE_INSTALL_FOLDER}"

    # Install

    local -r consoleJARFilePath="${SECRET_SERVER_CONSOLE_INSTALL_FOLDER}/$(basename "${SECRET_SERVER_CONSOLE_DOWNLOAD_URL}")"

    downloadFile "${SECRET_SERVER_CONSOLE_DOWNLOAD_URL}" "${consoleJARFilePath}" 'true'
    chown -R "$(whoami):$(whoami)" "${SECRET_SERVER_CONSOLE_INSTALL_FOLDER}"

    # Display Version

    displayVersion "$(java -jar "${consoleJARFilePath}" -version)"
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING SECRET SERVER CONSOLE'

    installDependencies
    install
    installCleanUp
}

main "${@}"