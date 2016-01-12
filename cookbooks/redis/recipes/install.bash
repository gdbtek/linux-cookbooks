#!/bin/bash -e

function installDependencies()
{
    installAptGetPackages 'build-essential'
}

function install()
{
    # Clean Up

    initializeFolder "${REDIS_INSTALL_BIN_FOLDER}"
    initializeFolder "${REDIS_INSTALL_CONFIG_FOLDER}"
    initializeFolder "${REDIS_INSTALL_DATA_FOLDER}"

    # Install

    local -r currentPath="$(pwd)"
    local -r tempFolder="$(getTemporaryFolder)"

    unzipRemoteFile "${REDIS_DOWNLOAD_URL}" "${tempFolder}"
    cd "${tempFolder}"
    make
    find "${tempFolder}/src" -type f -not -name '*.sh' -perm -u+x -exec cp -f '{}' "${REDIS_INSTALL_BIN_FOLDER}" \;
    rm -f -r "${tempFolder}"
    cd "${currentPath}"

    # Config Server

    local -r serverConfigData=(
        '__INSTALL_DATA_FOLDER__' "${REDIS_INSTALL_DATA_FOLDER}"
        6379 "${REDIS_PORT}"
    )

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/redis.conf.conf" "${REDIS_INSTALL_CONFIG_FOLDER}/redis.conf" "${serverConfigData[@]}"

    # Config Profile

    local -r profileConfigData=('__INSTALL_BIN_FOLDER__' "${REDIS_INSTALL_BIN_FOLDER}")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/redis.sh.profile" '/etc/profile.d/redis.sh' "${profileConfigData[@]}"

    # Config Upstart

    local -r upstartConfigData=(
        '__INSTALL_BIN_FOLDER__' "${REDIS_INSTALL_BIN_FOLDER}"
        '__INSTALL_CONFIG_FOLDER__' "${REDIS_INSTALL_CONFIG_FOLDER}"
        '__USER_NAME__' "${REDIS_USER_NAME}"
        '__GROUP_NAME__' "${REDIS_GROUP_NAME}"
    )

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/redis.conf.upstart" "/etc/init/${REDIS_SERVICE_NAME}.conf" "${upstartConfigData[@]}"

    # Config System

    local -r overCommitMemoryConfig="vm.overcommit_memory = ${REDIS_VM_OVER_COMMIT_MEMORY}"

    appendToFileIfNotFound '/etc/sysctl.conf' "$(stringToSearchPattern "${overCommitMemoryConfig}")" "\n${overCommitMemoryConfig}" 'true' 'true' 'true'
    sysctl "$(deleteSpaces "${overCommitMemoryConfig}")"

    # Start

    addUser "${REDIS_USER_NAME}" "${REDIS_GROUP_NAME}" 'false' 'true' 'false'
    chown -R "${REDIS_USER_NAME}:${REDIS_GROUP_NAME}" "${REDIS_INSTALL_BIN_FOLDER}" "${REDIS_INSTALL_CONFIG_FOLDER}" "${REDIS_INSTALL_DATA_FOLDER}"
    start "${REDIS_SERVICE_NAME}"

    # Display Open Ports

    displayOpenPorts '5'

    # Display Version

    info "\n$("${REDIS_INSTALL_BIN_FOLDER}/redis-server" --version)"
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING REDIS'

    checkRequirePort "${REDIS_PORT}"

    installDependencies
    install
    installCleanUp
}

main "${@}"