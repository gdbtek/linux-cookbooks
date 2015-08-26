#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'java')" = 'false' || ! -d "${ELASTIC_SEARCH_JDK_INSTALL_FOLDER}" ]]
    then
        "${appPath}/../../jdk/recipes/install.bash" "${ELASTIC_SEARCH_JDK_INSTALL_FOLDER}"
    fi
}

function install()
{
    # Clean Up

    initializeFolder "${ELASTIC_SEARCH_INSTALL_FOLDER}"

    # Install

    unzipRemoteFile "${ELASTIC_SEARCH_DOWNLOAD_URL}" "${ELASTIC_SEARCH_INSTALL_FOLDER}"

    # Config Server

    local -r serverConfigData=(
        '__HTTP_PORT__' "${ELASTIC_SEARCH_HTTP_PORT}"
        '__TRANSPORT_TCP_PORT__' "${ELASTIC_SEARCH_TRANSPORT_TCP_PORT}"
    )

    createFileFromTemplate  "${appPath}/../templates/default/elasticsearch.yml.conf" "${ELASTIC_SEARCH_INSTALL_FOLDER}/config/elasticsearch.yml" "${serverConfigData[@]}"

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER__' "${ELASTIC_SEARCH_INSTALL_FOLDER}")

    createFileFromTemplate "${appPath}/../templates/default/elastic-search.sh.profile" '/etc/profile.d/elastic-search.sh' "${profileConfigData[@]}"

    # Config Upstart

    local -r upstartConfigData=(
        '__INSTALL_FOLDER__' "${ELASTIC_SEARCH_INSTALL_FOLDER}"
        '__JDK_INSTALL_FOLDER__' "${ELASTIC_SEARCH_JDK_INSTALL_FOLDER}"
        '__USER_NAME__' "${ELASTIC_SEARCH_USER_NAME}"
        '__GROUP_NAME__' "${ELASTIC_SEARCH_GROUP_NAME}"
    )

    createFileFromTemplate "${appPath}/../templates/default/elastic-search.conf.upstart" "/etc/init/${ELASTIC_SEARCH_SERVICE_NAME}.conf" "${upstartConfigData[@]}"

    # Start

    addUser "${ELASTIC_SEARCH_USER_NAME}" "${ELASTIC_SEARCH_GROUP_NAME}" 'false' 'true' 'false'
    chown -R "${ELASTIC_SEARCH_USER_NAME}:${ELASTIC_SEARCH_GROUP_NAME}" "${ELASTIC_SEARCH_INSTALL_FOLDER}"
    start "${ELASTIC_SEARCH_SERVICE_NAME}"

    # Display Version

    info "\n$("${ELASTIC_SEARCH_INSTALL_FOLDER}/bin/elasticsearch" -v)"
}

function main()
{
    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING ELASTIC SEARCH'

    checkRequirePort "${ELASTIC_SEARCH_HTTP_PORT}" "${ELASTIC_SEARCH_TRANSPORT_TCP_PORT}"

    installDependencies
    install
    installCleanUp

    displayOpenPorts '5'
}

main "${@}"