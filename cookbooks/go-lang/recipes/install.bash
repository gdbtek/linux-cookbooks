#!/bin/bash -e

function install()
{
    umask '0022'

    initializeFolder "${GO_LANG_INSTALL_FOLDER_PATH}"
    unzipRemoteFile "${GO_LANG_DOWNLOAD_URL}" "${GO_LANG_INSTALL_FOLDER_PATH}"
    chown -R "$(whoami):$(whoami)" "${GO_LANG_INSTALL_FOLDER_PATH}"
    symlinkUsrBin "${GO_LANG_INSTALL_FOLDER_PATH}/bin"
    ln -f -s "${GO_LANG_INSTALL_FOLDER_PATH}" '/usr/local/go'

    createFileFromTemplate \
        "$(dirname "${BASH_SOURCE[0]}")/../templates/go-lang.sh.profile" \
        '/etc/profile.d/go-lang.sh' \
        '__INSTALL_FOLDER_PATH__' "${GO_LANG_INSTALL_FOLDER_PATH}"

    export GOROOT="${GO_LANG_INSTALL_FOLDER_PATH}"
    displayVersion "$(go version)"

    umask '0077'
}

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    header 'INSTALLING GO-LANG'

    checkRequireLinuxSystem
    checkRequireRootUser

    install
    installCleanUp
}

main "${@}"