#!/bin/bash

function installDependencies()
{
    apt-get update

    apt-get install -y unzip
}

function install()
{
    local currentPath="$(pwd)"
    local zipFile="${installFolder}/$(basename "${downloadURL}")"

    # Clean Up

    rm -rf "${installFolder}"
    mkdir -p "${installFolder}"

    # Install

    curl -L "${downloadURL}" -o "${zipFile}"
    unzip -q "${zipFile}" -d "${installFolder}"
    rm -f "${zipFile}"
    cd "${installFolder}"
    npm install --production --silent
    cd "${currentPath}"

    # Config Server

    local serverConfigData=(
        'http://my-ghost-blog.com' "${url}"
        '127.0.0.1' "${host}"
        2369 "${port}"
    )

    updateTemplateFile "${installFolder}/config.example.js" "${installFolder}/config.js" "${serverConfigData[@]}"

    # Config Upstart

    local upstartConfigData=(
        '__INSTALL_FOLDER__' "${installFolder}"
        '__UID__' "${uid}"
        '__GID__' "${gid}"
    )

    updateTemplateFile "${appPath}/../files/upstart/ghost.conf" "/etc/init/${serviceName}.conf" "${upstartConfigData[@]}"

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
    checkPortRequirement "${port}"

    installDependencies
    install

    displayOpenPorts
}

main "${@}"
