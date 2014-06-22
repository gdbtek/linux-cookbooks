#!/bin/bash

function install()
{
    # Clean Up

    rm -rf "${golangInstallFolder}" '/usr/local/bin/go' '/usr/local/bin/godoc' '/usr/local/bin/gofmt' '/usr/local/go'
    mkdir -p "${golangInstallFolder}"

    # Install

    unzipRemoteFile "${golangDownloadURL}" "${golangInstallFolder}"
    chown -R "$(whoami)":"$(whoami)" "${golangInstallFolder}"
    symlinkLocalBin "${golangInstallFolder}/bin"
    ln -s "${golangInstallFolder}" '/usr/local/go'

    # Config Profile

    local profileConfigData=('__INSTALL_FOLDER__' "${golangInstallFolder}")

    createFileFromTemplate "${appPath}/../files/profile/go-lang.sh" '/etc/profile.d/go-lang.sh' "${profileConfigData[@]}"

    # Display Version

    export GOROOT="${golangInstallFolder}" && info "\n$(go version)"
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    checkRequireDistributor

    header 'INSTALLING GO-LANG'

    checkRequireRootUser

    install
    installCleanUp
}

main "${@}"