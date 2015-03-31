#!/bin/bash -e

function install()
{
    # Clean Up

    initializeFolder "${awscliInstallFolder}"

    # Install

    local tempFolder="$(getTemporaryFolder)"

    unzipRemoteFile "${ec2amitoolsDownloadURL}" "${tempFolder}"
    # rm -f -r "${tempFolder}"

    # Config Profile

    local profileConfigData=('__INSTALL_FOLDER__' "${ec2amitoolsInstallFolder}")

    createFileFromTemplate "${appPath}/../templates/default/ec2-ami-tools.sh.profile" '/etc/profile.d/ec2-ami-tools.sh' "${profileConfigData[@]}"

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

    header 'INSTALLING EC2-AMI-TOOLS'

    install
    installCleanUp
}

main "${@}"