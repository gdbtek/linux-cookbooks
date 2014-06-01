#!/bin/bash

function installDependencies()
{
    apt-get update

    apt-get install -y build-essential
}

function install()
{
    # Install

    local currentPath="$(pwd)"
    local tempFolder="$(getTemporaryFolder)"

    unzipRemoteFile "${downloadURL}" "${tempFolder}"
    cd "${tempFolder}"
    "${tempFolder}/vmware-install.pl"
    rm -rf "${tempFolder}"
    cd "${currentPath}"
}

function main()
{
    local appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    checkRequireDistributor

    header 'INSTALLING VMWARE-TOOLS'

    checkRequireRootUser

    installDependencies
    install
    installCleanUp
}

main "${@}"
