#!/bin/bash -e

function installDependencies()
{
    installPackages 'python'
}

function install()
{
    umask '0022'

    local -r tempFolder="$(getTemporaryFolder)"

    initializeFolder "${AWS_CLI_INSTALL_FOLDER_PATH}"
    unzipRemoteFile "${AWS_CLI_DOWNLOAD_URL}" "${tempFolder}"
    python "${tempFolder}/awscli-bundle/install" \
        -b '/usr/bin/aws' \
        -i "${AWS_CLI_INSTALL_FOLDER_PATH}"
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

    installDependencies
    install
    installCleanUp
}

main "${@}"