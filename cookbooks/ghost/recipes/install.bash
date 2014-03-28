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

    rm -rf "${installFolder}"
    mkdir -p "${installFolder}"

    curl -L "${downloadURL}" -o "${zipFile}"
    unzip "${zipFile}" -d "${installFolder}"
    rm -f "${zipFile}"
    cd "${installFolder}"
    npm install --production
    cd "${currentPath}"

    # Update Config File

    local tempFile="$(mktemp)"

    local oldURL="$(escapeSearchPattern 'http://my-ghost-blog.com')"
    local newURL="$(escapeSearchPattern "${url}")"

    local oldHost="$(escapeSearchPattern '127.0.0.1')"
    local newHost="$(escapeSearchPattern "${host}")"

    local oldPort="$(escapeSearchPattern '2369')"
    local newPort="$(escapeSearchPattern "${port}")"

    sed "s@${oldURL}@${newURL}@g" "${installFolder}/config.example.js" | \
    sed "s@${oldHost}@${newHost}@g" | \
    sed "s@${oldPort}@${newPort}@g" | \
    tee "${tempFile}"

    mv -f "${tempFile}" "${installFolder}/config.js"
    cp -f "${appPath}/../files/upstart/ghost.conf" "${etcInitFile}"

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

    sleep 3
    displayOpenPorts
}

main "${@}"
