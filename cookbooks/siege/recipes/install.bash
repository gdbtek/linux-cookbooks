#!/bin/bash

function installDependencies()
{
    runAptGetUpdate

    installPackage 'build-essential'
}

function install()
{
    # Clean Up

    rm -rf "${siegeInstallFolder}"
    mkdir -p "${siegeInstallFolder}/bin"

    # Install

    local currentPath="$(pwd)"
    local tempFolder="$(getTemporaryFolder)"

    curl -L "${siegeDownloadURL}" | tar x --strip 1 -C "${tempFolder}"
    cd "${tempFolder}"
    "${tempFolder}/configure" --prefix="${siegeInstallFolder}"
    make
    make install
    rm -rf "${tempFolder}"
    cd "${currentPath}"

    # Config Profile

    local profileConfigData=('__INSTALL_FOLDER__' "${siegeInstallFolder}")

    createFileFromTemplate "${appPath}/../files/profile/siege.sh" '/etc/profile.d/siege.sh' "${profileConfigData[@]}"
}

function main()
{
    local appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    checkRequireDistributor

    header 'INSTALLING SIEGE'

    installDependencies
    install
    installCleanUp
}

main "${@}"