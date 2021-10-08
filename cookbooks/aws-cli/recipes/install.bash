#!/bin/bash -e

function install()
{
    umask '0022'

    local -r tempFolder="$(getTemporaryFolder)"

    initializeFolder "${AWS_CLI_INSTALL_FOLDER_PATH}"
    unzipRemoteFile "${AWS_CLI_DOWNLOAD_URL}" "${tempFolder}"
    "${tempFolder}/aws/install" --update
    rm -f -r "${tempFolder}"
    chown -R "$(whoami):$(whoami)" "${AWS_CLI_INSTALL_FOLDER_PATH}"
    symlinkListUsrBin "${AWS_CLI_INSTALL_FOLDER_PATH}/bin/aws"
    displayVersion "$('/usr/bin/aws' --version 2>&1)"

    umask '0077'
}

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    header 'INSTALLING AWS-CLI'

    checkRequireLinuxSystem
    checkRequireRootUser

    install
    installCleanUp
}

main "${@}"