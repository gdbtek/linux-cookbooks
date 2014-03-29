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
    unzip "${zipFile}" -d "${installFolder}"
    rm -f "${zipFile}"
    cd "${installFolder}"
    npm install --production
    cd "${currentPath}"

    # Config

    local oldURL="$(escapeSearchPattern 'http://my-ghost-blog.com')"
    local newURL="$(escapeSearchPattern "${url}")"
    local oldHost="$(escapeSearchPattern '127.0.0.1')"
    local newHost="$(escapeSearchPattern "${host}")"

    sed "s@${oldURL}@${newURL}@g" "${installFolder}/config.example.js" | \
    sed "s@${oldHost}@${newHost}@g" | \
    sed "s@2369@${port}@g" \
    > "${installFolder}/config.js"

    cp -f "${appPath}/../files/upstart/ghost.conf" "/etc/init/${serviceName}.conf"

    # Start

    start ghost
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
