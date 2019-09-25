#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'java')" = 'false' || ! -d "${GOCD_JDK_INSTALL_FOLDER_PATH}" ]]
    then
        "$(dirname "${BASH_SOURCE[0]}")/../../jdk/recipes/install.bash" "${GOCD_JDK_INSTALL_FOLDER_PATH}"
    fi
}

function install()
{
    local serverHostname="${1}"

    umask '0022'

    # Clean Up

    initializeFolder "${GOCD_AGENT_INSTALL_FOLDER_PATH}"

    # Install

    unzipRemoteFile "${GOCD_AGENT_DOWNLOAD_URL}" "${GOCD_AGENT_INSTALL_FOLDER_PATH}"

    local -r unzipFolder="$(find "${GOCD_AGENT_INSTALL_FOLDER_PATH}" -maxdepth 1 -xtype d 2> '/dev/null' | tail -1)"

    if [[ "$(isEmptyString "${unzipFolder}")" = 'true' || "$(trimString "$(wc -l <<< "${unzipFolder}")")" != '1' ]]
    then
        fatal 'FATAL : multiple unzip folder names found'
    fi

    if [[ "$(ls -A "${unzipFolder}")" = '' ]]
    then
        fatal "FATAL : folder '${unzipFolder}' empty"
    fi

    # Move Folder

    moveFolderContent "${unzipFolder}" "${GOCD_AGENT_INSTALL_FOLDER_PATH}"

    # Finalize

    addUser "${GOCD_USER_NAME}" "${GOCD_GROUP_NAME}" 'true' 'false' 'true'
    chown -R "${GOCD_USER_NAME}:${GOCD_GROUP_NAME}" "${GOCD_AGENT_INSTALL_FOLDER_PATH}"
    rm -f -r "${unzipFolder}"

    # Config Init

    if [[ "$(isEmptyString "${serverHostname}")" = 'true' ]]
    then
        serverHostname='127.0.0.1'
    fi

    local -r initConfigData=(
        '__AGENT_INSTALL_FOLDER_PATH__' "${GOCD_AGENT_INSTALL_FOLDER_PATH}"
        '__SERVER_HOSTNAME__' "${serverHostname}"
        '__GO_HOME_FOLDER__' "$(getUserHomeFolder "${GOCD_USER_NAME}")"
        '__USER_NAME__' "${GOCD_USER_NAME}"
        '__GROUP_NAME__' "${GOCD_GROUP_NAME}"
    )

    createInitFileFromTemplate "${GOCD_AGENT_SERVICE_NAME}" "$(dirname "${BASH_SOURCE[0]}")/../templates" "${initConfigData[@]}"

    # Start

    startService "${GOCD_AGENT_SERVICE_NAME}"

    umask '0077'
}

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    header 'INSTALLING GOCD AGENT'

    checkRequireLinuxSystem
    checkRequireRootUser

    installDependencies
    install "${@}"
    installCleanUp
}

main "${@}"