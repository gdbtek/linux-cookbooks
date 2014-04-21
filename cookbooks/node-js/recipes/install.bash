#!/bin/bash

function installDependencies()
{
    apt-get update

    apt-get install -y build-essential
}

function install()
{
    # Clean Up

    rm -rf "${installFolder}" '/usr/local/bin/node' '/usr/local/bin/npm'
    mkdir -p "${installFolder}"

    # Install

    local latestVersionNumber="$(getLatestVersionNumber)"

    unzipRemoteFile "http://nodejs.org/dist/latest/node-v${latestVersionNumber}-linux-x64.tar.gz" "${installFolder}"
    chown -R "$(whoami)":"$(whoami)" "${installFolder}"
    ln -s "${installFolder}/bin/node" '/usr/local/bin/node'
    ln -s "${installFolder}/bin/npm" '/usr/local/bin/npm'

    # Config Profile

    local profileConfigData=('__INSTALL_FOLDER__' "${installFolder}")

    createFileFromTemplate "${appPath}/../files/profile/node-js.sh" '/etc/profile.d/node-js.sh' "${profileConfigData[@]}"
}

function getLatestVersionNumber()
{
    local versionPattern='[[:digit:]]{1,2}\.[[:digit:]]{1,2}\.[[:digit:]]{1,3}'
    local shaSum256="$(getRemoteFileContent 'http://nodejs.org/dist/latest/SHASUMS256.txt.asc')"

    echo "${shaSum256}" | egrep -o "node-v${versionPattern}\.tar\.gz" | egrep -o "${versionPattern}"
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    header 'INSTALLING NODE-JS'

    checkRequireRootUser

    installDependencies
    install
}

main "${@}"
