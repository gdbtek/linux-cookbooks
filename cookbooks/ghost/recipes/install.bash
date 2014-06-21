#!/bin/bash

function install()
{
    # Clean Up

    rm -rf "${ghostInstallFolder}"
    mkdir -p "${ghostInstallFolder}"

    # Install

    local currentPath="$(pwd)"

    unzipRemoteFile "${ghostDownloadURL}" "${ghostInstallFolder}"
    cd "${ghostInstallFolder}"
    npm install --production --silent
    cd "${currentPath}"

    # Config Server

    local serverConfigData=(
        'http://my-ghost-blog.com' "${ghostURL}"
        '127.0.0.1' "${ghostHost}"
        2369 "${ghostPort}"
    )

    createFileFromTemplate "${ghostInstallFolder}/config.example.js" "${ghostInstallFolder}/config.js" "${serverConfigData[@]}"

    # Config Upstart

    local upstartConfigData=(
        '__INSTALL_FOLDER__' "${ghostInstallFolder}"
        '__UID__' "${ghostUID}"
        '__GID__' "${ghostGID}"
    )

    createFileFromTemplate "${appPath}/../files/upstart/ghost.conf" "/etc/init/${ghostServiceName}.conf" "${upstartConfigData[@]}"

    # Start

    addSystemUser "${ghostUID}" "${ghostGID}"
    chown -R "${ghostUID}":"${ghostGID}" "${ghostInstallFolder}"
    start "${ghostServiceName}"
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    checkRequireDistributor

    header 'INSTALLING GHOST'

    checkRequireRootUser
    checkRequirePort "${ghostPort}"

    install
    installCleanUp

    displayOpenPorts
}

main "${@}"