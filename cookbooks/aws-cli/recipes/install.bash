#!/bin/bash -e

function install()
{
    # Clean Up

    initializeFolder "${awscliInstallFolder:?}"

    # Install

    local -r tempFolder="$(getTemporaryFolder)"

    unzipRemoteFile "${awscliDownloadURL:?}" "${tempFolder}"
    "${tempFolder}/awscli-bundle/install" -b '/usr/local/bin/aws' -i "${awscliInstallFolder}"
    rm -f -r "${tempFolder}"

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER__' "${awscliInstallFolder}")

    createFileFromTemplate "${appPath}/../templates/default/aws-cli.sh.profile" '/etc/profile.d/aws-cli.sh' "${profileConfigData[@]}"

    # Display Version

    info "\n$("${awscliInstallFolder}/bin/aws" --version 2>&1)"
}

function main()
{
    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING AWS-CLI'

    install
    installCleanUp
}

main "${@}"