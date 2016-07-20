#!/bin/bash -e

function installDependencies()
{
    installAptGetPackages 'python'
}

function install()
{
    # Clean Up

    initializeFolder "${AWS_CLI_INSTALL_FOLDER}"

    # Install

    local -r tempFolder="$(getTemporaryFolder)"

    unzipRemoteFile "${AWS_CLI_DOWNLOAD_URL}" "${tempFolder}"
    python "${tempFolder}/awscli-bundle/install" -b '/usr/local/bin/aws' -i "${AWS_CLI_INSTALL_FOLDER}"
    rm -f -r "${tempFolder}"

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER__' "${AWS_CLI_INSTALL_FOLDER}")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/aws-cli.sh.profile" '/etc/profile.d/aws-cli.sh' "${profileConfigData[@]}"

    # Display Version

    displayVersion "$("${AWS_CLI_INSTALL_FOLDER}/bin/aws" --version 2>&1)"
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING AWS-CLI'

    installDependencies
    install
    installCleanUp
}

main "${@}"