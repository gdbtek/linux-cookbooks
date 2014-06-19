#!/bin/bash

function install()
{
    # Clean Up

    rm -rf "${serverInstallFolder}"
    mkdir -p "${serverInstallFolder}"

    # Install

    addSystemUser "${uid}" "${gid}"
    unzipRemoteFile "${serverDownloadURL}" "${serverInstallFolder}"
    cd "${installFolder}"
    local unzipFolderName="$(find * -maxdepth 0 -type d)"
    mv "${unzipFolderName}/* .
    rm -rf "${unzipFolderName}"

    exit
}

function configUpstart()
{
    local upstartConfigData=(
        '__SERVER_INSTALL_FOLDER__' "${serverInstallFolder}"
        '__UID__' 'go'
        '__GID__' 'go'
    )

    createFileFromTemplate "${appPath}/../files/upstart/go-server.conf" "/etc/init/go-server.conf" "${upstartConfigData[@]}"
}

function startServer()
{
    service go-server start
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    checkRequireDistributor

    header 'INSTALLING GO-SERVER (SERVER)'

    checkRequireRootUser
    checkRequirePort '8153' '8154'

    install
    startServer
    installCleanUp

    displayOpenPorts
}

main "${@}"
