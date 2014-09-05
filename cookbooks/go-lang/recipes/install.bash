#!/bin/bash -e

function installDependencies()
{
    installAptGetPackages 'mercurial' 'bzr'
}

function install()
{
    # Clean Up

    initializeFolder "${golangInstallFolder}"
    rm -f '/usr/local/bin/go' '/usr/local/bin/godoc' '/usr/local/bin/gofmt' '/usr/local/go'

    # Install

    unzipRemoteFile "${golangDownloadURL}" "${golangInstallFolder}"
    chown -R "$(whoami):$(whoami)" "${golangInstallFolder}"
    symlinkLocalBin "${golangInstallFolder}/bin"
    ln -s "${golangInstallFolder}" '/usr/local/go'

    # Config Profile

    local profileConfigData=('__INSTALL_FOLDER__' "${golangInstallFolder}")

    createFileFromTemplate "${appPath}/../templates/default/go-lang.sh.profile" '/etc/profile.d/go-lang.sh' "${profileConfigData[@]}"

    # Display Version

    export GOROOT="${golangInstallFolder}"
    info "$(go version)"
}

function main()
{
    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../lib/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING GO-LANG'

    installDependencies
    install
    installCleanUp
}

main "${@}"