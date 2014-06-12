#!/bin/bash

function installDependencies()
{
    runAptGetUpdate

    installPackage 'build-essential'
}

function install()
{
    # Clean Up

    rm -rf "${installFolder}" '/usr/local/bin/node' '/usr/local/bin/npm'
    mkdir -p "${installFolder}"

    # Install

    if [[ "${version}" = 'latest' ]]
    then
        version="$(getLatestVersionNumber)"
        local url="http://nodejs.org/dist/latest/node-v${version}-linux-x64.tar.gz"
    else
        local url="http://nodejs.org/dist/v${version}/node-v${version}-linux-x64.tar.gz"
    fi

    if [[ "$(existURL "${url}")" = 'true' ]]
    then
        unzipRemoteFile "${url}" "${installFolder}"
        chown -R "$(whoami)":"$(whoami)" "${installFolder}"
        symlinkLocalBin "${installFolder}/bin"

        # Config Profile

        local profileConfigData=('__INSTALL_FOLDER__' "${installFolder}")

        createFileFromTemplate "${appPath}/../files/profile/node-js.sh" '/etc/profile.d/node-js.sh' "${profileConfigData[@]}"
    else
        fatal "\nFATAL: version '${version}' not found!"
    fi
}

function getLatestVersionNumber()
{
    local versionPattern='[[:digit:]]{1,2}\.[[:digit:]]{1,2}\.[[:digit:]]{1,3}'
    local shaSum256="$(getRemoteFileContent 'http://nodejs.org/dist/latest/SHASUMS256.txt.asc')"

    echo "${shaSum256}" | grep -Eo "node-v${versionPattern}\.tar\.gz" | grep -Eo "${versionPattern}"
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    checkRequireDistributor

    header 'INSTALLING NODE-JS'

    checkRequireRootUser

    installDependencies
    install
    installCleanUp
}

main "${@}"
