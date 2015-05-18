#!/bin/bash -e

function install()
{
    # Clean Up

    initializeFolder "${kibanaInstallFolder:?}"

    # Install

    unzipRemoteFile "${kibanaDownloadURL:?}" "${kibanaInstallFolder}"

    # Config

    local -r configData=('"http://"+window.location.hostname+":9200"' "\"${kibanaElasticSearchURL}\"")

    createFileFromTemplate "${kibanaInstallFolder}/config.js" "${kibanaInstallFolder}/config.js" "${configData[@]}"
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