#!/bin/bash -e

function install()
{
    umask '0022'

    initializeFolder "${GO_INSTALL_FOLDER_PATH}"
    unzipRemoteFile "${GO_DOWNLOAD_URL}" "${GO_INSTALL_FOLDER_PATH}"
    chown -R "$(whoami):$(whoami)" "${GO_INSTALL_FOLDER_PATH}"
    symlinkUsrBin "${GO_INSTALL_FOLDER_PATH}/bin"
    ln -f -s "${GO_INSTALL_FOLDER_PATH}" '/usr/local/go'

    createFileFromTemplate \
        "$(dirname "${BASH_SOURCE[0]}")/../templates/go.sh.profile" \
        '/etc/profile.d/go.sh' \
        '__INSTALL_FOLDER_PATH__' "${GO_INSTALL_FOLDER_PATH}"

    export GOROOT="${GO_INSTALL_FOLDER_PATH}"
    displayVersion "$(go version)"

    umask '0077'
}

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    header 'INSTALLING GO'

    checkRequireLinuxSystem
    checkRequireRootUser

    install
    installCleanUp
}

main "${@}"