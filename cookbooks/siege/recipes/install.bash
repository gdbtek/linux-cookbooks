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

    compileAndInstallFromSource "${SIEGE_DOWNLOAD_URL}" "${SIEGE_INSTALL_FOLDER_PATH}" "${SIEGE_INSTALL_FOLDER_PATH}/bin/siege" "$(whoami)"

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER_PATH__' "${SIEGE_INSTALL_FOLDER_PATH}")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/siege.sh.profile" '/etc/profile.d/siege.sh' "${profileConfigData[@]}"

    # Display Version

    displayVersion "$("${SIEGE_INSTALL_FOLDER_PATH}/bin/siege" --version 2>&1)"

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