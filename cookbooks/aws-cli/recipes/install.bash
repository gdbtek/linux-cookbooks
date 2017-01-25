#!/bin/bash -e

function installDependencies()
{
    installPackages 'python'
}

function install()
{
    umask '0022'

    # Clean Up

    initializeFolder "${AWS_CLI_INSTALL_FOLDER_PATH}"

    # Install

    local -r tempFolder="$(getTemporaryFolder)"

    unzipRemoteFile "${AWS_CLI_DOWNLOAD_URL}" "${tempFolder}"
    python "${tempFolder}/awscli-bundle/install" -b '/usr/local/bin/aws' -i "${AWS_CLI_INSTALL_FOLDER_PATH}"
    chmod 755 "${AWS_CLI_INSTALL_FOLDER_PATH}/bin/aws"
    rm -f -r "${tempFolder}"

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER_PATH__' "${AWS_CLI_INSTALL_FOLDER_PATH}")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/aws-cli.sh.profile" '/etc/profile.d/aws-cli.sh' "${profileConfigData[@]}"

    # Display Version

    displayVersion "$("${AWS_CLI_INSTALL_FOLDER_PATH}/bin/aws" --version 2>&1)"

    umask '0077'
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING AWS-CLI'

    installDependencies
    install
    installCleanUp
}

main "${@}"