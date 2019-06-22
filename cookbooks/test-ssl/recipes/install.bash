#!/bin/bash -e

function install()
{
    umask '0022'

    initializeFolder "${TEST_SSL_INSTALL_FOLDER_PATH}"

    unzipRemoteFile "${TEST_SSL_DOWNLOAD_URL}" "${TEST_SSL_INSTALL_FOLDER_PATH}"
    chown -R "$(whoami):$(whoami)" "${TEST_SSL_INSTALL_FOLDER_PATH}"
    symlinkListUsrBin "${TEST_SSL_INSTALL_FOLDER_PATH}/testssl.sh"

    createFileFromTemplate \
        "$(dirname "${BASH_SOURCE[0]}")/../templates/test-ssl.sh.profile" \
        '/etc/profile.d/test-ssl.sh' \
        '__INSTALL_FOLDER_PATH__' "${TEST_SSL_INSTALL_FOLDER_PATH}"

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