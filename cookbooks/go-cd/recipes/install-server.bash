#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'java')" = 'false' || ! -d "${GO_CD_JDK_INSTALL_FOLDER}" ]]
    then
        "${APP_FOLDER_PATH}/../../jdk/recipes/install.bash" "${GO_CD_JDK_INSTALL_FOLDER}"
    fi
}

function install()
{
    # Clean Up

    initializeFolder "${GO_CD_SERVER_INSTALL_FOLDER}"

    # Install

    unzipRemoteFile "${GO_CD_SERVER_DOWNLOAD_URL}" "${GO_CD_SERVER_INSTALL_FOLDER}"

    local -r unzipFolder="$(find "${GO_CD_SERVER_INSTALL_FOLDER}" -maxdepth 1 -xtype d 2> '/dev/null' | tail -1)"

    if [[ "$(isEmptyString "${unzipFolder}")" = 'true' || "$(wc -l <<< "${unzipFolder}")" != '1' ]]
    then
        fatal 'FATAL : multiple unzip folder names found'
    fi

    if [[ "$(ls -A "${unzipFolder}")" = '' ]]
    then
        fatal "FATAL : folder '${unzipFolder}' empty"
    fi

    # Move Folder

    moveFolderContent "${unzipFolder}" "${GO_CD_SERVER_INSTALL_FOLDER}"

    # Finalize

    addUser "${GO_CD_USER_NAME}" "${GO_CD_GROUP_NAME}" 'true' 'false' 'true'
    chown -R "${GO_CD_USER_NAME}:${GO_CD_GROUP_NAME}" "${GO_CD_SERVER_INSTALL_FOLDER}"
    rm -f -r "${unzipFolder}"

    # Config Systemd

    local -r upstartConfigData=(
        '__SERVER_INSTALL_FOLDER__' "${GO_CD_SERVER_INSTALL_FOLDER}"
        '__GO_HOME_FOLDER__' "$(getUserHomeFolder "${GO_CD_USER_NAME}")"
        '__USER_NAME__' "${GO_CD_USER_NAME}"
        '__GROUP_NAME__' "${GO_CD_GROUP_NAME}"
    )

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/server.conf.upstart" "/etc/init/${GO_CD_SERVER_SERVICE_NAME}.conf" "${upstartConfigData[@]}"
    start "${GO_CD_SERVER_SERVICE_NAME}"

    # Display Open Ports

    displayOpenPorts '45'
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING GO-CD SERVER'

    checkRequirePort '8153' '8154'

    installDependencies
    install
    installCleanUp
}

main "${@}"