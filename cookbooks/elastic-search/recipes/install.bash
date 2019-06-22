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

    initializeFolder "${ELASTIC_SEARCH_INSTALL_FOLDER_PATH}"
    unzipRemoteFile "${ELASTIC_SEARCH_DOWNLOAD_URL}" "${ELASTIC_SEARCH_INSTALL_FOLDER_PATH}"

    createFileFromTemplate \
        "$(dirname "${BASH_SOURCE[0]}")/../templates/elastic-search.sh.profile" \
        '/etc/profile.d/elastic-search.sh' \
        '__INSTALL_FOLDER_PATH__' "${ELASTIC_SEARCH_INSTALL_FOLDER_PATH}"

    createInitFileFromTemplate \
        "${ELASTIC_SEARCH_SERVICE_NAME}" \
        "$(dirname "${BASH_SOURCE[0]}")/../templates" \
        '__INSTALL_FOLDER_PATH__' "${ELASTIC_SEARCH_INSTALL_FOLDER_PATH}" \
        '__JDK_INSTALL_FOLDER_PATH__' "${ELASTIC_SEARCH_JDK_INSTALL_FOLDER_PATH}" \
        '__USER_NAME__' "${ELASTIC_SEARCH_USER_NAME}" \
        '__GROUP_NAME__' "${ELASTIC_SEARCH_GROUP_NAME}"

    addUser "${ELASTIC_SEARCH_USER_NAME}" "${ELASTIC_SEARCH_GROUP_NAME}" 'false' 'true' 'false'
    chown -R "${ELASTIC_SEARCH_USER_NAME}:${ELASTIC_SEARCH_GROUP_NAME}" "${ELASTIC_SEARCH_INSTALL_FOLDER_PATH}"
    startService "${ELASTIC_SEARCH_SERVICE_NAME}"

    displayOpenPorts '10'
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