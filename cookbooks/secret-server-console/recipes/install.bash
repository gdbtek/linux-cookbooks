#!/bin/bash -e

function install()
{
    # Clean Up

    initializeFolder "${SECRET_SERVER_CONSOLE_INSTALL_FOLDER}"
    mkdir -p "${SECRET_SERVER_CONSOLE_INSTALL_FOLDER}"

    # Install

    local -r consoleJARFilePath="${SECRET_SERVER_CONSOLE_INSTALL_FOLDER}/$(getFileName "${SECRET_SERVER_CONSOLE_DOWNLOAD_URL}")"

    downloadFile "${SECRET_SERVER_CONSOLE_DOWNLOAD_URL}" "${consoleJARFilePath}" 'true'
    chown -R "$(whoami):$(whoami)" "${SECRET_SERVER_CONSOLE_INSTALL_FOLDER}"
    chmod 755 "${SECRET_SERVER_CONSOLE_INSTALL_FOLDER}/jq"

    # Display Version

    info "\n$("${consoleJARFilePath}" -version)"
}

function main()
{
    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../../../libraries/util.bash"
    source "${appFolderPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING SECRET SERVER CONSOLE'

    install
    installCleanUp
}

main "${@}"