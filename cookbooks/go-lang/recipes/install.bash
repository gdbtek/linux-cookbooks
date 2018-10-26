#!/bin/bash -e

function install()
{
    umask '0022'

    # Clean Up

    initializeFolder "${GO_LANG_INSTALL_FOLDER_PATH}"

    # Install

    unzipRemoteFile "${GO_LANG_DOWNLOAD_URL}" "${GO_LANG_INSTALL_FOLDER_PATH}"
    chown -R "$(whoami):$(whoami)" "${GO_LANG_INSTALL_FOLDER_PATH}"
    symlinkLocalBin "${GO_LANG_INSTALL_FOLDER_PATH}/bin"
    ln -f -s "${GO_LANG_INSTALL_FOLDER_PATH}" '/usr/local/go'

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER_PATH__' "${GO_LANG_INSTALL_FOLDER_PATH}")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/go-lang.sh.profile" '/etc/profile.d/go-lang.sh' "${profileConfigData[@]}"

    # Display Version

    export GOROOT="${GO_LANG_INSTALL_FOLDER_PATH}"
    displayVersion "$(go version)"

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

    header 'INSTALLING GO-LANG'

    # Override Default Config

    if [[ "$(isEmptyString "${installFolder}")" = 'false' ]]
    then
        GO_LANG_INSTALL_FOLDER_PATH="${installFolder}"
    fi

    # Install

    install
    installCleanUp
}

main "${@}"