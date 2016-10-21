#!/bin/bash -e

function installDependencies()
{
    installPackages 'mercurial'
}

function install()
{
    umask '0022'

    # Clean Up

    initializeFolder "${GO_LANG_INSTALL_FOLDER}"

    # Install

    unzipRemoteFile "${GO_LANG_DOWNLOAD_URL}" "${GO_LANG_INSTALL_FOLDER}"
    chown -R "$(whoami):$(whoami)" "${GO_LANG_INSTALL_FOLDER}"
    symlinkLocalBin "${GO_LANG_INSTALL_FOLDER}/bin"
    ln -f -s "${GO_LANG_INSTALL_FOLDER}" '/usr/local/go'

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER__' "${GO_LANG_INSTALL_FOLDER}")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/go-lang.sh.profile" '/etc/profile.d/go-lang.sh' "${profileConfigData[@]}"

    # Display Version

    export GOROOT="${GO_LANG_INSTALL_FOLDER}"
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
        GO_LANG_INSTALL_FOLDER="${installFolder}"
    fi

    # Install

    installDependencies
    install
    installCleanUp
}

main "${@}"