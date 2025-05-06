#!/bin/bash -e

function installPython()
{
    umask '0022'
    add-apt-repository -y 'ppa:deadsnakes/ppa'
    apt-get update -m
    installPackages "${CQLSH_PYTHON_VERSION}"
    createFileFromTemplate \
        "$(dirname "${BASH_SOURCE[0]}")/../templates/cqlsh.sh.profile" \
        '/etc/profile.d/cqlsh.sh' \
        '__PYTHON_INTERPRETER_FILE_PATH__' \
        "/usr/bin/${CQLSH_PYTHON_VERSION}"
    umask '0077'
}

function installCQLSH()
{
    umask '0022'
    initializeFolder "${CQLSH_INSTALL_FOLDER_PATH}"
    unzipRemoteFile "${CQLSH_DOWNLOAD_URL}" "${CQLSH_INSTALL_FOLDER_PATH}"
    rm -f '/usr/bin/cqlsh'
    ln -f -s "${CQLSH_INSTALL_FOLDER_PATH}/bin/cqlsh" '/usr/bin/cqlsh'
    source '/etc/profile.d/cqlsh.sh'
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