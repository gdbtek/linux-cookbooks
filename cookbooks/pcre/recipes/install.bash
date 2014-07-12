#!/bin/bash

function installDependencies()
{
    runAptGetUpdate

    installAptGetPackage 'build-essential'
}

function install()
{
    # Clean Up

    rm -rf "${pcreInstallFolder}"
    mkdir -p "${pcreInstallFolder}"

    # Install

    local currentPath="$(pwd)"
    local tempFolder="$(getTemporaryFolder)"

    unzipRemoteFile "${pcreDownloadURL}" "${tempFolder}"
    cd "${tempFolder}"
    "${tempFolder}/configure" --prefix="${pcreInstallFolder}"
    make
    make install
    rm -rf "${tempFolder}"
    cd "${currentPath}"
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    checkRequireDistributor

    header 'INSTALLING PCRE'

    checkRequireRootUser

    installDependencies
    install
    installCleanUp
}

main "${@}"