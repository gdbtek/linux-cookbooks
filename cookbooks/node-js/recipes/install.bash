#!/bin/bash -e

function installDependencies()
{
    installAptGetPackages 'build-essential'
}

function install()
{
    # Clean Up

    initializeFolder "${nodejsInstallFolder}"
    rm -f '/usr/local/bin/node' '/usr/local/bin/npm'

    # Install

    if [[ "${nodejsVersion}" = 'latest' ]]
    then
        nodejsVersion="$(getLatestVersionNumber)"
        local url="http://nodejs.org/dist/latest/node-${nodejsVersion}-linux-x64.tar.gz"
    else
        if [[ "$(echo "${nodejsVersion}" | grep -o '^v')" = '' ]]
        then
            nodejsVersion="v${nodejsVersion}"
        fi

        local url="http://nodejs.org/dist/${nodejsVersion}/node-${nodejsVersion}-linux-x64.tar.gz"
    fi

    unzipRemoteFile "${url}" "${nodejsInstallFolder}"
    chown -R "$(whoami):$(whoami)" "${nodejsInstallFolder}"
    symlinkLocalBin "${nodejsInstallFolder}/bin"

    # Config Profile

    local profileConfigData=('__INSTALL_FOLDER__' "${nodejsInstallFolder}")

    createFileFromTemplate "${appPath}/../templates/default/node-js.sh.profile" '/etc/profile.d/node-js.sh' "${profileConfigData[@]}"

    info "\nNode Version: $(node --version)"
    info "NPM Version : $(npm --version)"
}

function getLatestVersionNumber()
{
    local versionPattern='v[[:digit:]]{1,2}\.[[:digit:]]{1,2}\.[[:digit:]]{1,3}'
    local shaSum256="$(getRemoteFileContent 'http://nodejs.org/dist/latest/SHASUMS256.txt.asc')"

    echo "${shaSum256}" | grep -E -o "node-${versionPattern}\.tar\.gz" | grep -E -o "${versionPattern}"
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING NODE-JS'

    installDependencies
    install
    installCleanUp
}

main "${@}"