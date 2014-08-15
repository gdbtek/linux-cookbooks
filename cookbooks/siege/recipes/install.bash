#!/bin/bash -e

function installDependencies()
{
    installAptGetPackages 'build-essential'
}

function install()
{
    # Clean Up

    rm --force --recursive "${siegeInstallFolder}"
    mkdir --parents "${siegeInstallFolder}/bin"

    # Install

    local currentPath="$(pwd)"
    local tempFolder="$(getTemporaryFolder)"

    unzipRemoteFile "${siegeDownloadURL}" "${tempFolder}"
    cd "${tempFolder}" &&
    "${tempFolder}/configure" --prefix="${siegeInstallFolder}" &&
    make &&
    make install
    rm --force --recursive "${tempFolder}"
    cd "${currentPath}"

    # Config Profile

    local profileConfigData=('__INSTALL_FOLDER__' "${siegeInstallFolder}")

    createFileFromTemplate "${appPath}/../templates/default/siege.sh.profile" '/etc/profile.d/siege.sh' "${profileConfigData[@]}"

    # Display Version

    info "\n$("${siegeInstallFolder}/bin/siege" --version)"
}

function main()
{
    local appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING SIEGE'

    installDependencies
    install
    installCleanUp
}

main "${@}"