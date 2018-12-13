#!/bin/bash -e

function installDependencies()
{
    installBuildEssential

    installPackages 'automake'
    installPackage 'libncurses-dev' 'ncurses-devel'
}

function install()
{
    umask '0022'

    # Install

    local -r tempFolder="$(getTemporaryFolder)"

    unzipRemoteFile "${MTR_DOWNLOAD_URL}" "${tempFolder}"
    cd "${tempFolder}"
    "${tempFolder}/bootstrap.sh"
    "${tempFolder}/configure" --prefix="${MTR_INSTALL_FOLDER_PATH}"
    make
    make install
    chown -R "$(whoami):$(getUserGroupName "$(whoami)")" "${MTR_INSTALL_FOLDER_PATH}"
    symlinkLocalBin "${MTR_INSTALL_FOLDER_PATH}/sbin/mtr"
    symlinkLocalBin "${MTR_INSTALL_FOLDER_PATH}/sbin/mtr-packet"
    rm -f -r "${tempFolder}"

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER_PATH__' "${MTR_INSTALL_FOLDER_PATH}")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/mtr.sh.profile" '/etc/profile.d/mtr.sh' "${profileConfigData[@]}"

    # Display Version

    displayVersion "$("${MTR_INSTALL_FOLDER_PATH}/sbin/mtr")"

    umask '0077'
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING MTR'

    installDependencies
    install
    installCleanUp
}

main "${@}"