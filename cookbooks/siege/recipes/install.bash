#!/bin/bash -e

function installDependencies()
{
    installBuildEssential
}

function install()
{
    umask '0022'

    # Clean Up

    initializeFolder "${SIEGE_INSTALL_FOLDER}"
    mkdir -p "${SIEGE_INSTALL_FOLDER}/bin"

    # Install

    local -r tempFolder="$(getTemporaryFolder)"

    unzipRemoteFile "${SIEGE_DOWNLOAD_URL}" "${tempFolder}"
    cd "${tempFolder}"
    "${tempFolder}/configure" --prefix="${SIEGE_INSTALL_FOLDER}"
    make
    make install
    rm -f -r "${tempFolder}"
    ln -f -s "${SIEGE_INSTALL_FOLDER}/bin/siege" '/usr/local/bin/siege'

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER__' "${SIEGE_INSTALL_FOLDER}")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/siege.sh.profile" '/etc/profile.d/siege.sh' "${profileConfigData[@]}"

    # Display Version

    displayVersion "$("${SIEGE_INSTALL_FOLDER}/bin/siege" --version 2>&1)"

    umask '0077'
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING SIEGE'

    installDependencies
    install
    installCleanUp
}

main "${@}"