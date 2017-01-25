#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'java')" = 'false' || ! -d "${GO_CD_JDK_INSTALL_FOLDER_PATH}" ]]
    then
        "${APP_FOLDER_PATH}/../../jdk/recipes/install.bash" "${GO_CD_JDK_INSTALL_FOLDER_PATH}"
    fi
}

function install()
{
    local serverHostname="${1}"

    umask '0022'

    # Clean Up

    initializeFolder "${GO_CD_AGENT_INSTALL_FOLDER_PATH}"

    # Install

    unzipRemoteFile "${GO_CD_AGENT_DOWNLOAD_URL}" "${GO_CD_AGENT_INSTALL_FOLDER_PATH}"

    local -r unzipFolder="$(find "${GO_CD_AGENT_INSTALL_FOLDER_PATH}" -maxdepth 1 -xtype d 2> '/dev/null' | tail -1)"

    if [[ "$(isEmptyString "${unzipFolder}")" = 'true' || "$(trimString "$(wc -l <<< "${unzipFolder}")")" != '1' ]]
    then
        fatal 'FATAL : multiple unzip folder names found'
    fi

    if [[ "$(ls -A "${unzipFolder}")" = '' ]]
    then
        fatal "FATAL : folder '${unzipFolder}' empty"
    fi

    # Move Folder

    moveFolderContent "${unzipFolder}" "${GO_CD_AGENT_INSTALL_FOLDER_PATH}"

    # Finalize

    addUser "${GO_CD_USER_NAME}" "${GO_CD_GROUP_NAME}" 'true' 'false' 'true'
    chown -R "${GO_CD_USER_NAME}:${GO_CD_GROUP_NAME}" "${GO_CD_AGENT_INSTALL_FOLDER_PATH}"
    rm -f -r "${unzipFolder}"

    # Config Init

    if [[ "$(isEmptyString "${serverHostname}")" = 'true' ]]
    then
        serverHostname='127.0.0.1'
    fi

    local -r initConfigData=(
        '__AGENT_INSTALL_FOLDER_PATH__' "${GO_CD_AGENT_INSTALL_FOLDER_PATH}"
        '__SERVER_HOSTNAME__' "${serverHostname}"
        '__GO_HOME_FOLDER__' "$(getUserHomeFolder "${GO_CD_USER_NAME}")"
        '__USER_NAME__' "${GO_CD_USER_NAME}"
        '__GROUP_NAME__' "${GO_CD_GROUP_NAME}"
    )

    createInitFileFromTemplate "${GO_CD_AGENT_SERVICE_NAME}" "${APP_FOLDER_PATH}/../templates" "${initConfigData[@]}"

    # Start

    startService "${GO_CD_AGENT_SERVICE_NAME}"

    umask '0077'
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING GO-CD AGENT'

    installDependencies
    install "${@}"
    installCleanUp
}

main "${@}"