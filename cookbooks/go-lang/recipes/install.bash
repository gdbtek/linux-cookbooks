#!/bin/bash

function install()
{
    # Clean Up

    rm -rf "${golangInstallFolder}" '/usr/local/bin/go' '/usr/local/bin/godoc' '/usr/local/bin/gofmt'
    mkdir -p "${golangInstallFolder}"

    # Install

    unzipRemoteFile "${golangDownloadURL}" "${golangInstallFolder}"
    chown -R "$(whoami)":"$(whoami)" "${golangInstallFolder}"
    symlinkLocalBin "${golangInstallFolder}/bin"

    # Config Profile

    local profileConfigData=('__INSTALL_FOLDER__' "${golangInstallFolder}")

    createFileFromTemplate "${appPath}/../files/profile/go-lang.sh" '/etc/profile.d/go-lang.sh' "${profileConfigData[@]}"
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
