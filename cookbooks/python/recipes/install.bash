#!/bin/bash -e

function installDependencies()
{
    installBuildEssential
}

function install()
{
    umask '0022'

    # Install

    compileAndInstallFromSource "${PYTHON_DOWNLOAD_URL}" "${PYTHON_INSTALL_FOLDER_PATH}" "${PYTHON_INSTALL_FOLDER_PATH}/bin/python3" "$(whoami)"
    ln -f -s "${PYTHON_INSTALL_FOLDER_PATH}/bin/python3" '/usr/local/bin/python'

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER_PATH__' "${PYTHON_INSTALL_FOLDER_PATH}")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/python.sh.profile" '/etc/profile.d/python.sh' "${profileConfigData[@]}"

    # Display Version

    displayVersion "$(python3 --version)"

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

    header 'INSTALLING PYTHON'

    # Override Default Config

    if [[ "$(isEmptyString "${installFolder}")" = 'false' ]]
    then
        PYTHON_INSTALL_FOLDER_PATH="${installFolder}"
    fi

    # Install

    installDependencies
    install
    installCleanUp
}

main "${@}"