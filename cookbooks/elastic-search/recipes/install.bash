#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'java')" = 'false' || ! -d "${ELASTIC_SEARCH_JDK_INSTALL_FOLDER_PATH}" ]]
    then
        "$(dirname "${BASH_SOURCE[0]}")/../../jdk/recipes/install.bash" "${ELASTIC_SEARCH_JDK_INSTALL_FOLDER_PATH}"
    fi
}

function install()
{
    umask '0022'

    # Clean Up

    initializeFolder "${ELASTIC_SEARCH_INSTALL_FOLDER_PATH}"

    # Install

    unzipRemoteFile "${ELASTIC_SEARCH_DOWNLOAD_URL}" "${ELASTIC_SEARCH_INSTALL_FOLDER_PATH}"

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER_PATH__' "${ELASTIC_SEARCH_INSTALL_FOLDER_PATH}")

    createFileFromTemplate "$(dirname "${BASH_SOURCE[0]}")/../templates/elastic-search.sh.profile" '/etc/profile.d/elastic-search.sh' "${profileConfigData[@]}"

    # Config Init

    local -r initConfigData=(
        '__INSTALL_FOLDER_PATH__' "${ELASTIC_SEARCH_INSTALL_FOLDER_PATH}"
        '__JDK_INSTALL_FOLDER_PATH__' "${ELASTIC_SEARCH_JDK_INSTALL_FOLDER_PATH}"
        '__USER_NAME__' "${ELASTIC_SEARCH_USER_NAME}"
        '__GROUP_NAME__' "${ELASTIC_SEARCH_GROUP_NAME}"
    )

    createInitFileFromTemplate "${ELASTIC_SEARCH_SERVICE_NAME}" "$(dirname "${BASH_SOURCE[0]}")/../templates" "${initConfigData[@]}"

    # Start

    addUser "${ELASTIC_SEARCH_USER_NAME}" "${ELASTIC_SEARCH_GROUP_NAME}" 'false' 'true' 'false'
    chown -R "${ELASTIC_SEARCH_USER_NAME}:${ELASTIC_SEARCH_GROUP_NAME}" "${ELASTIC_SEARCH_INSTALL_FOLDER_PATH}"
    startService "${ELASTIC_SEARCH_SERVICE_NAME}"

    # Display Open Ports

    displayOpenPorts '10'

    # Display Version

    displayVersion "$(elasticsearch --version)"

    umask '0077'
}

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    header 'INSTALLING ELASTIC SEARCH'

    checkRequireLinuxSystem
    checkRequireRootUser
    checkRequirePorts '9200' '9300'

    installDependencies
    install
    installCleanUp
}

main "${@}"