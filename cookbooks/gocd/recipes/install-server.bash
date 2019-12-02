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

    initializeFolder "${GOCD_SERVER_INSTALL_FOLDER_PATH}"

    # Install

    unzipRemoteFile "${GOCD_SERVER_DOWNLOAD_URL}" "${GOCD_SERVER_INSTALL_FOLDER_PATH}"

    local -r unzipFolder="$(
        find "${GOCD_SERVER_INSTALL_FOLDER_PATH}" \
            -maxdepth 1 \
            -xtype d \
        2> '/dev/null' |
        tail -1
    )"

    if [[ "$(isEmptyString "${unzipFolder}")" = 'true' || "$(trimString "$(wc -l <<< "${unzipFolder}")")" != '1' ]]
    then
        fatal 'FATAL : multiple unzip folder names found'
    fi

    if [[ "$(ls -A "${unzipFolder}")" = '' ]]
    then
        fatal "FATAL : folder '${unzipFolder}' empty"
    fi

    # Move Folder

    moveFolderContent "${unzipFolder}" "${GOCD_SERVER_INSTALL_FOLDER_PATH}"

    # Finalize

    addUser "${GOCD_USER_NAME}" "${GOCD_GROUP_NAME}" 'true' 'false' 'true'
    chown -R "${GOCD_USER_NAME}:${GOCD_GROUP_NAME}" "${GOCD_SERVER_INSTALL_FOLDER_PATH}"
    rm -f -r "${unzipFolder}"

    # Config Init

    createInitFileFromTemplate \
        "${GOCD_SERVER_SERVICE_NAME}" \
        "$(dirname "${BASH_SOURCE[0]}")/../templates" \
        '__SERVER_INSTALL_FOLDER_PATH__' "${GOCD_SERVER_INSTALL_FOLDER_PATH}" \
        '__GO_HOME_FOLDER__' "$(getUserHomeFolder "${GOCD_USER_NAME}")" \
        '__USER_NAME__' "${GOCD_USER_NAME}" \
        '__GROUP_NAME__' "${GOCD_GROUP_NAME}"

    # Start

    startService "${GOCD_SERVER_SERVICE_NAME}"

    # Display Open Ports

    displayOpenPorts '45'

    umask '0077'
}

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    header 'INSTALLING GOCD SERVER'

    checkRequireLinuxSystem
    checkRequireRootUser
    checkRequirePorts '8153' '8154'

    installDependencies
    install
    installCleanUp
}

main "${@}"