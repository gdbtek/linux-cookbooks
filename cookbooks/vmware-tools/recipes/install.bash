#!/bin/bash -e

function installDependencies()
{
    installAptGetPackages 'build-essential'
}

function install()
{
    # Install

    local -r currentPath="$(pwd)"
    local -r tempFolder="$(getTemporaryFolder)"

    unzipRemoteFile "${vmwaretoolsDownloadURL}" "${tempFolder}"
    cd "${tempFolder}"
    "${tempFolder}/vmware-install.pl"
    rm -f -r "${tempFolder}"
    cd "${currentPath}"
}

function main()
{
    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING VMWARE-TOOLS'

    installDependencies
    install
    installCleanUp
}

main "${@}"