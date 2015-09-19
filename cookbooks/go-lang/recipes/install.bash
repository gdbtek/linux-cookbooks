#!/bin/bash -e

function installDependencies()
{
    installAptGetPackages 'mercurial'
}

function install()
{
    # Clean Up

    initializeFolder "${GO_LANG_INSTALL_FOLDER}"

    # Install

    unzipRemoteFile "${GO_LANG_DOWNLOAD_URL}" "${GO_LANG_INSTALL_FOLDER}"
    chown -R "$(whoami):$(whoami)" "${GO_LANG_INSTALL_FOLDER}"
    symlinkLocalBin "${GO_LANG_INSTALL_FOLDER}/bin"
    ln -f -s "${GO_LANG_INSTALL_FOLDER}" '/usr/local/go'

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER__' "${GO_LANG_INSTALL_FOLDER}")

    createFileFromTemplate "${appPath}/../templates/go-lang.sh.profile" '/etc/profile.d/go-lang.sh' "${profileConfigData[@]}"

    # Display Version

    export GOROOT="${GO_LANG_INSTALL_FOLDER}"
    info "$(go version)"
}

function main()
{
    local -r installFolder="${1}"

    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # shellcheck source=/dev/null
    source "${appPath}/../../../libraries/util.bash"
    # shellcheck source=/dev/null
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
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