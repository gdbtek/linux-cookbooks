#!/bin/bash -e

function installDependencies()
{
    installBuildEssential

    installPackage 'libffi-dev' 'libffi-devel'
    installPackage 'libssl-dev' 'openssl-devel'
    installPackage 'zlib1g-dev' 'zlib-devel'
}

function install()
{
    umask '0022'

    # Install

    compileAndInstallFromSource "${PYTHON_DOWNLOAD_URL}" "${PYTHON_INSTALL_FOLDER_PATH}" "${PYTHON_INSTALL_FOLDER_PATH}/bin/python3" "$(whoami)"
    symlinkListUsrBin "${PYTHON_INSTALL_FOLDER_PATH}/bin/python3"

    # Config Profile

    createFileFromTemplate \
        "$(dirname "${BASH_SOURCE[0]}")/../templates/python.sh.profile" \
        '/etc/profile.d/python.sh' \
        '__INSTALL_FOLDER_PATH__' "${PYTHON_INSTALL_FOLDER_PATH}"

    # Display Version

    displayVersion "$(python3 --version)"

    umask '0077'
}

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    header 'INSTALLING PYTHON'

    checkRequireLinuxSystem
    checkRequireRootUser

    installDependencies
    install
    installCleanUp
}

main "${@}"