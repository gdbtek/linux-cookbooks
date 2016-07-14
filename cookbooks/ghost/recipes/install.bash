#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'node')" = 'false' || "$(existCommand 'npm')" = 'false' || ! -d "${GHOST_NODE_JS_INSTALL_FOLDER}" ]]
    then
        "${APP_FOLDER_PATH}/../../node-js/recipes/install.bash" "${GHOST_NODE_JS_VERSION}" "${GHOST_NODE_JS_INSTALL_FOLDER}"
    fi
}

function install()
{
    # Clean Up

    initializeFolder "${GHOST_INSTALL_FOLDER}"

    # Install

    unzipRemoteFile "${GHOST_DOWNLOAD_URL}" "${GHOST_INSTALL_FOLDER}"
    cd "${GHOST_INSTALL_FOLDER}"
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

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/config.js.conf" "${GHOST_INSTALL_FOLDER}/config.js" "${serverConfigData[@]}"

    # Config Init

    local -r initConfigData=(
        '__ENVIRONMENT__' "${GHOST_ENVIRONMENT}"
        '__INSTALL_FOLDER__' "${GHOST_INSTALL_FOLDER}"
        '__USER_NAME__' "${GHOST_USER_NAME}"
        '__GROUP_NAME__' "${GHOST_GROUP_NAME}"
    )

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/ghost.conf.upstart" "/etc/init/${GHOST_SERVICE_NAME}.conf" "${initConfigData[@]}"

    # Start

    addUser "${GHOST_USER_NAME}" "${GHOST_GROUP_NAME}" 'false' 'true' 'false'
    chown -R "${GHOST_USER_NAME}:${GHOST_GROUP_NAME}" "${GHOST_INSTALL_FOLDER}"
    start "${GHOST_SERVICE_NAME}"

    # Display Open Ports

    displayOpenPorts '5'
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING GHOST'

    if [[ "${GHOST_ENVIRONMENT}" = 'production' ]]
    then
        checkRequirePort "${GHOST_PRODUCTION_PORT}"
    elif [[ "${GHOST_ENVIRONMENT}" = 'development' ]]
    then
        checkRequirePort "${GHOST_DEVELOPMENT_PORT}"
    else
        fatal "\nFATAL : environment '${GHOST_ENVIRONMENT}' not supported"
    fi

    installDependencies
    install
    installCleanUp
}

main "${@}"