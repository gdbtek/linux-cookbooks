#!/bin/bash -e

function install()
{
    # Clean Up

    rm -rf "${kibanaInstallFolder}"
    mkdir -p "${kibanaInstallFolder}"

    # Install

    unzipRemoteFile "${kibanaDownloadURL}" "${kibanaInstallFolder}"

    # Config

    local configData=('"http://"+window.location.hostname+":9200"' "\"${kibanaElasticSearchURL}\"")

    createFileFromTemplate "${kibanaInstallFolder}/config.js" "${kibanaInstallFolder}/config.js" "${configData[@]}"
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1
    source "${appPath}/../../nginx/attributes/default.bash" || exit 1

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING KIBANA'

    install
    installCleanUp
}

main "${@}"