#!/bin/bash

function getLatestVersionNumber()
{
    local versionPattern='[[:digit:]]{1,2}\.[[:digit:]]{1,2}\.[[:digit:]]{1,3}'
    local shaSums256="$(curl -s -X 'GET' "${shaSums256URL}")"

    echo "${shaSums256}" | egrep -o "node-v${versionPattern}\.tar\.gz" | egrep -o "${versionPattern}"
}

function installDependencies()
{
    apt-get update

    apt-get install -y build-essential
    apt-get install -y curl
}

function install()
{
    local latestVersionNumber="$(getLatestVersionNumber)"

    rm -rf "${installFolder}" '/usr/local/bin/node' '/usr/local/bin/npm'
    mkdir -p "${installFolder}"

    curl -L "http://nodejs.org/dist/v${latestVersionNumber}/node-v${latestVersionNumber}-linux-x64.tar.gz" | \
    tar xz --strip 1 -C "${installFolder}"
    ln -s "${installFolder}/bin/node" '/usr/local/bin/node'
    ln -s "${installFolder}/bin/npm" '/usr/local/bin/npm'

    echo "export PATH=\"${installFolder}/bin:\$PATH\"" > "${etcProfileFile}"
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
