#!/bin/bash -e

function installDependencies()
{
    installAptGetPackages 'mercurial'
}

function install()
{
    # Clean Up

    initializeFolder "${golangInstallFolder}"

    # Install

    unzipRemoteFile "${golangDownloadURL}" "${golangInstallFolder}"
    chown -R "$(whoami):$(whoami)" "${golangInstallFolder}"
    symlinkLocalBin "${golangInstallFolder}/bin"
    ln -f -s "${golangInstallFolder}" '/usr/local/go'

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER__' "${golangInstallFolder}")

    createFileFromTemplate "${appPath}/../templates/default/go-lang.sh.profile" '/etc/profile.d/go-lang.sh' "${profileConfigData[@]}"

    # Display Version

    export GOROOT="${golangInstallFolder}"
    info "$(go version)"
}

function main()
{
    local -r installFolder="${1}"

    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING GO-LANG'

    # Override Default Config

    if [[ "$(isEmptyString "${installFolder}")" = 'false' ]]
    then
        golangInstallFolder="${installFolder}"
    fi

    # Install

    installDependencies
    install
    installCleanUp
}

main "${@}"