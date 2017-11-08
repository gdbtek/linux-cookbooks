#!/bin/bash -e

function install()
{
    umask '0022'

    # Clean Up

    initializeFolder "${TEST_SSL_INSTALL_FOLDER_PATH}"

    # Install

    unzipRemoteFile "${TEST_SSL_DOWNLOAD_URL}" "${TEST_SSL_INSTALL_FOLDER_PATH}"
    chown -R "$(whoami):$(whoami)" "${TEST_SSL_INSTALL_FOLDER_PATH}"
    ln -f -s "${TEST_SSL_INSTALL_FOLDER_PATH}/testssl.sh" '/usr/local/bin/testssl'

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER_PATH__' "${TEST_SSL_INSTALL_FOLDER_PATH}")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/test-ssl.sh.profile" '/etc/profile.d/test-ssl.sh' "${profileConfigData[@]}"

    # Display Version

    displayVersion "$("${TEST_SSL_INSTALL_FOLDER_PATH}/testssl.sh" -v)"

    umask '0077'
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING TEST-SSL'

    install
    installCleanUp
}

main "${@}"