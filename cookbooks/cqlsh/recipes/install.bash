#!/bin/bash -e

function installPython()
{
    umask '0022'
    add-apt-repository -y 'ppa:deadsnakes/ppa'
    apt-get update -m
    installPackages "${CQLSH_PYTHON_VERSION}"
    rm -f '/usr/bin/python3'
    ln -s -f "/usr/bin/${CQLSH_PYTHON_VERSION}" '/usr/bin/python3'
    umask '0077'
}

function installCQLSH()
{
    umask '0022'
    initializeFolder "${CQLSH_INSTALL_FOLDER_PATH}"
    unzipRemoteFile "${CQLSH_DOWNLOAD_URL}" "${CQLSH_INSTALL_FOLDER_PATH}"
    rm -f '/usr/bin/cqlsh'
    ln -f -s "${CQLSH_INSTALL_FOLDER_PATH}/bin/cqlsh" '/usr/bin/cqlsh'
    '/usr/bin/cqlsh' --version
    umask '0077'
}

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    header 'INSTALLING CQLSH'

    checkRequireLinuxSystem
    checkRequireRootUser

    installPython
    installCQLSH
}

main "${@}"