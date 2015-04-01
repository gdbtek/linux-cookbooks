#!/bin/bash -e

function installDependencies()
{
    installAptGetPackages 'build-essential'
}

function install()
{
    # Clean Up

    initializeFolder "${nodejsInstallFolder}"

    # Install

    if [[ "${nodejsVersion}" = 'latest' ]]
    then
        nodejsVersion="$(getLatestVersionNumber)"
        local url="http://nodejs.org/dist/latest/node-${nodejsVersion}-linux-x64.tar.gz"
    else
        if [[ "$(grep -o '^v' <<< "${nodejsVersion}")" = '' ]]
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

    # Install NPM Packages

    local package=''

    for package in "${nodejsInstallNPMPackages[@]}"
    do
        header "INSTALLING NODE-JS NPM PACKAGE ${package}"
        npm install "${package}" -g
    done

    # Display Version

    info "Node Version: $(node --version)"
    info "NPM Version : $(npm --version)"
}

function getLatestVersionNumber()
{
    local versionPattern='v[[:digit:]]{1,2}\.[[:digit:]]{1,2}\.[[:digit:]]{1,3}'
    local shaSum256="$(getRemoteFileContent 'http://nodejs.org/dist/latest/SHASUMS256.txt.asc')"

    grep -E -o "node-${versionPattern}\.tar\.gz" <<< "${shaSum256}" | grep -E -o "${versionPattern}"
}

function main()
{
    local installFolder="${1}"
    local version="${2}"

    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING NODE-JS'

    # Override Default Config

    if [[ "$(isEmptyString "${installFolder}")" = 'false' ]]
    then
        nodejsInstallFolder="${installFolder}"
    fi

    if [[ "$(isEmptyString "${version}")" = 'false' ]]
    then
        nodejsVersion="${version}"
    fi

    # Install

    installDependencies
    install
    installCleanUp
}

main "${@}"