#!/bin/bash -e

function install()
{
    # Clean Up

    initializeFolder "${KIBANA_INSTALL_FOLDER}"

    # Install

    unzipRemoteFile "${KIBANA_DOWNLOAD_URL}" "${KIBANA_INSTALL_FOLDER}"

    # Config

    local -r configData=('"http://"+window.location.hostname+":9200"' "\"${KIBANA_ELASTIC_SEARCH_URL}\"")

    createFileFromTemplate "${KIBANA_INSTALL_FOLDER}/config.js" "${KIBANA_INSTALL_FOLDER}/config.js" "${configData[@]}"
}

function main()
{
    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/default.bash"
    source "${appPath}/../../nginx/attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING KIBANA'

    install
    installCleanUp
}

main "${@}"