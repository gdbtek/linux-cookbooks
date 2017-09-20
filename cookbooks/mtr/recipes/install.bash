#!/bin/bash -e

function installDependencies()
{
    installBuildEssential

    installPackage 'zlib1g-dev' 'zlib-devel'
}

function install()
{
    umask '0022'

    # Install

    compileAndInstallFromSource "${MTR_DOWNLOAD_URL}" "${MTR_INSTALL_FOLDER_PATH}" "${MTR_INSTALL_FOLDER_PATH}/bin/mtr" "$(whoami)"

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER_PATH__' "${MTR_INSTALL_FOLDER_PATH}")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/mtr.sh.profile" '/etc/profile.d/mtr.sh' "${profileConfigData[@]}"

    # Display Version

    displayVersion "$("${MTR_INSTALL_FOLDER_PATH}/bin/mtr" --version 2>&1)"

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