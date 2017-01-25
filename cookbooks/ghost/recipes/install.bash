#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'node')" = 'false' || "$(existCommand 'npm')" = 'false' || ! -d "${GHOST_NODE_JS_INSTALL_FOLDER_PATH}" ]]
    then
        "${APP_FOLDER_PATH}/../../node-js/recipes/install.bash" "${GHOST_NODE_JS_VERSION}" "${GHOST_NODE_JS_INSTALL_FOLDER_PATH}"
    fi
}

function install()
{
    umask '0022'

    # Clean Up

    initializeFolder "${GHOST_INSTALL_FOLDER_PATH}"

    # Install

    unzipRemoteFile "${GHOST_DOWNLOAD_URL}" "${GHOST_INSTALL_FOLDER_PATH}"
    cd "${GHOST_INSTALL_FOLDER_PATH}"
    npm install "--${GHOST_ENVIRONMENT}" --silent

    # Config Server

    local -r serverConfigData=(
        '__PRODUCTION_URL__' "${GHOST_PRODUCTION_URL}"
        '__PRODUCTION_HOST__' "${GHOST_PRODUCTION_HOST}"
        '__PRODUCTION_PORT__' "${GHOST_PRODUCTION_PORT}"

        '__DEVELOPMENT_URL__' "${GHOST_DEVELOPMENT_URL}"
        '__DEVELOPMENT_HOST__' "${GHOST_DEVELOPMENT_HOST}"
        '__DEVELOPMENT_PORT__' "${GHOST_DEVELOPMENT_PORT}"

        '__TESTING_URL__' "${GHOST_TESTING_URL}"
        '__TESTING_HOST__' "${GHOST_TESTING_HOST}"
        '__TESTING_PORT__' "${GHOST_TESTING_PORT}"
    )

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/config.js.conf" "${GHOST_INSTALL_FOLDER_PATH}/config.js" "${serverConfigData[@]}"

    # Config Init

    local -r initConfigData=(
        '__ENVIRONMENT__' "${GHOST_ENVIRONMENT}"
        '__INSTALL_FOLDER_PATH__' "${GHOST_INSTALL_FOLDER_PATH}"
        '__USER_NAME__' "${GHOST_USER_NAME}"
        '__GROUP_NAME__' "${GHOST_GROUP_NAME}"
    )

    createInitFileFromTemplate "${GHOST_SERVICE_NAME}" "${APP_FOLDER_PATH}/../templates" "${initConfigData[@]}"

    # Start

    addUser "${GHOST_USER_NAME}" "${GHOST_GROUP_NAME}" 'false' 'true' 'false'
    chown -R "${GHOST_USER_NAME}:${GHOST_GROUP_NAME}" "${GHOST_INSTALL_FOLDER_PATH}"
    startService "${GHOST_SERVICE_NAME}"

    # Display Open Ports

    displayOpenPorts '5'

    umask '0077'
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING GHOST'

    if [[ "${GHOST_ENVIRONMENT}" = 'production' ]]
    then
        checkRequirePorts "${GHOST_PRODUCTION_PORT}"
    elif [[ "${GHOST_ENVIRONMENT}" = 'development' ]]
    then
        checkRequirePorts "${GHOST_DEVELOPMENT_PORT}"
    else
        fatal "\nFATAL : environment '${GHOST_ENVIRONMENT}' not supported"
    fi

    installDependencies
    install
    installCleanUp
}

main "${@}"