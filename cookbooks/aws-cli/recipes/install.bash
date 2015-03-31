#!/bin/bash -e

function install()
{
    # Clean Up

    initializeFolder "${awscliInstallFolder}"

    # Install

    local currentPath="$(pwd)"
    local tempFolder="$(getTemporaryFolder)"

    unzipRemoteFile "${awscliDownloadURL}" "${tempFolder}"
    cd "${tempFolder}"

    rm -f -r "${tempFolder}"
    cd "${currentPath}"

    # Config Profile

    local profileConfigData=('__INSTALL_FOLDER__' "${haproxyInstallFolder}")

    createFileFromTemplate "${appPath}/../templates/default/haproxy.sh.profile" '/etc/profile.d/haproxy.sh' "${profileConfigData[@]}"

    # Display Version

    info "\n$("${awscliInstallFolder}/bin/aws" --version 2>&1)"
}

function main()
{
    local appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING AWS-CLI'

    install
    installCleanUp
}

main "${@}"