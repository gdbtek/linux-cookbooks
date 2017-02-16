#!/bin/bash -e

function installDependencies()
{
    installBuildEssential
}

function install()
{
    umask '0022'

    # Install

    compileAndInstallFromSource "${PARALLEL_DOWNLOAD_URL}" "${PARALLEL_INSTALL_FOLDER_PATH}" "${PARALLEL_INSTALL_FOLDER_PATH}/bin/parallel" "$(whoami)"

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER_PATH__' "${PARALLEL_INSTALL_FOLDER_PATH}")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/parallel.sh.profile" '/etc/profile.d/parallel.sh' "${profileConfigData[@]}"

    # Display Version

    displayVersion "$(parallel --version)"

    umask '0077'
}

function main()
{
    local -r installFolder="${1}"

    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING PARALLEL'

    # Override Default Config

    if [[ "$(isEmptyString "${installFolder}")" = 'false' ]]
    then
        PARALLEL_INSTALL_FOLDER_PATH="${installFolder}"
    fi

    # Install

    installDependencies
    install
    installCleanUp
}

main "${@}"