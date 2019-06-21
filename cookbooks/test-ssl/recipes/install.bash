#!/bin/bash -e

function install()
{
    umask '0022'

    # Clean Up

    initializeFolder "${TEST_SSL_INSTALL_FOLDER_PATH}"

    # Install

    unzipRemoteFile "${TEST_SSL_DOWNLOAD_URL}" "${TEST_SSL_INSTALL_FOLDER_PATH}"
    chown -R "$(whoami):$(whoami)" "${TEST_SSL_INSTALL_FOLDER_PATH}"
    ln -f -s "${TEST_SSL_INSTALL_FOLDER_PATH}/testssl.sh" '/usr/bin/testssl'

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER_PATH__' "${TEST_SSL_INSTALL_FOLDER_PATH}")

    createFileFromTemplate "$(dirname "${BASH_SOURCE[0]}")/../templates/test-ssl.sh.profile" '/etc/profile.d/test-ssl.sh' "${profileConfigData[@]}"

    # Display Version

    displayVersion "$(testssl.sh -v)"

    umask '0077'
}

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    header 'INSTALLING TEST-SSL'

    checkRequireLinuxSystem
    checkRequireRootUser

    install
    installCleanUp
}

main "${@}"