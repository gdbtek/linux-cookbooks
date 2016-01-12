#!/bin/bash -e

function installDependencies()
{
    installAptGetPackages 'build-essential'
}

function install()
{
    # Clean Up

    initializeFolder "${SIEGE_INSTALL_FOLDER}"
    mkdir -p "${SIEGE_INSTALL_FOLDER}/bin"

    # Install

    local -r currentPath="$(pwd)"
    local -r tempFolder="$(getTemporaryFolder)"

    unzipRemoteFile "${SIEGE_DOWNLOAD_URL}" "${tempFolder}"
    cd "${tempFolder}"
    "${tempFolder}/configure" --prefix="${SIEGE_INSTALL_FOLDER}"
    make
    make install
    rm -f -r "${tempFolder}"
    cd "${currentPath}"

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER__' "${SIEGE_INSTALL_FOLDER}")

    createFileFromTemplate "${appFolderPath}/../templates/siege.sh.profile" '/etc/profile.d/siege.sh' "${profileConfigData[@]}"

    # Display Version

    info "\n$("${SIEGE_INSTALL_FOLDER}/bin/siege" --version)"
}

function main()
{
    appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../../../libraries/util.bash"
    source "${appFolderPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING SIEGE'

    installDependencies
    install
    installCleanUp
}

main "${@}"