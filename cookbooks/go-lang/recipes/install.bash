#!/bin/bash -e

function install()
{
    umask '0022'

    # Clean Up

    initializeFolder "${GO_LANG_INSTALL_FOLDER_PATH}"

    # Install

    unzipRemoteFile "${GO_LANG_DOWNLOAD_URL}" "${GO_LANG_INSTALL_FOLDER_PATH}"
    chown -R "$(whoami):$(whoami)" "${GO_LANG_INSTALL_FOLDER_PATH}"
    symlinkUsrBin "${GO_LANG_INSTALL_FOLDER_PATH}/bin"
    ln -f -s "${GO_LANG_INSTALL_FOLDER_PATH}" '/usr/local/go'

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER_PATH__' "${GO_LANG_INSTALL_FOLDER_PATH}")

    createFileFromTemplate "$(dirname "${BASH_SOURCE[0]}")/../templates/go-lang.sh.profile" '/etc/profile.d/go-lang.sh' "${profileConfigData[@]}"

    # Display Version

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