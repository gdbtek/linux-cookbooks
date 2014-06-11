#!/bin/bash

function installDependencies()
{
    runAptGetUpdate

    installPackage 'default-jre-headless'
}

function install()
{
    # Clean Up

    rm -rf "${serverInstallFolder}"
    mkdir -p "${serverInstallFolder}"

    ln -s "${serverInstallFolder}" '/var/lib/go-server'

    # Install

    local serverPackageFile="$(getTemporaryFile "$(getFileExtension "${serverDownloadURL}")")"

    curl -L "${serverDownloadURL}" -o "${serverPackageFile}" &&
    dpkg -i "${serverPackageFile}" &&
    chown -R 'go:go' "${serverInstallFolder}"

    # Clean Up

    rm -f "${serverPackageFile}"
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

    installDependencies
    install
    startServer
    installCleanUp

    displayOpenPorts
}

main "${@}"
