#!/bin/bash

function install()
{
    # Clean Up

    rm -rf "${installFolder}"
    mkdir -p "${installFolder}"

    # Install

    local currentPath="$(pwd)"

    unzipRemoteFile "${downloadURL}" "${installFolder}"
    cd "${installFolder}"
    npm install --production --silent
    cd "${currentPath}"

    # Config Server

    local serverConfigData=(
        'http://my-ghost-blog.com' "${url}"
        '127.0.0.1' "${host}"
        2369 "${port}"
    )

    createFileFromTemplate "${installFolder}/config.example.js" "${installFolder}/config.js" "${serverConfigData[@]}"

    # Config Upstart

    local upstartConfigData=(
        '__INSTALL_FOLDER__' "${installFolder}"
        '__UID__' "${uid}"
        '__GID__' "${gid}"
    )

    createFileFromTemplate "${appPath}/../files/upstart/ghost.conf" "/etc/init/${serviceName}.conf" "${upstartConfigData[@]}"

    # Start

    addSystemUser "${uid}" "${gid}"
    chown -R "${uid}":"${gid}" "${installFolder}"
    start "${serviceName}"
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    header 'INSTALLING GHOST'

    checkRequireRootUser
    checkRequirePort "${port}"

    install
    installCleanUp

    displayOpenPorts
}

main "${@}"
