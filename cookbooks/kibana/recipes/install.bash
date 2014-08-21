#!/bin/bash -e

function install()
{
    # Clean Up

    rm --force --recursive "${kibanaInstallFolder}"
    mkdir --parents "${kibanaInstallFolder}"

    # Install

    unzipRemoteFile "${kibanaDownloadURL}" "${kibanaInstallFolder}"

    # Config

    local configData=('"http://"+window.location.hostname+":9200"' "\"${kibanaElasticSearchURL}\"")

    createFileFromTemplate "${kibanaInstallFolder}/config.js" "${kibanaInstallFolder}/config.js" "${configData[@]}"
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash"
    source "${appPath}/../attributes/default.bash"
    source "${appPath}/../../nginx/attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING KIBANA'

    install
    installCleanUp
}

main "${@}"